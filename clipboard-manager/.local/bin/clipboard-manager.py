#!/usr/bin/env -S /usr/bin/python3 -u
"""Minimal X11 ICCCM clipboard manager.

Owns the CLIPBOARD_MANAGER selection and responds to SAVE_TARGETS
conversion requests by snarfing the current CLIPBOARD owner's data and
taking CLIPBOARD ownership itself. This is what arboard (used by stu
and other Rust apps) needs to hand off clipboard contents before the
owning process exits.

Why this exists: CopyQ, gpaste, and xfce4-clipman do NOT implement the
ICCCM clipboard manager protocol on Linux/X11. arboard's `Drop` impl
sends `ConvertSelection(CLIPBOARD_MANAGER, SAVE_TARGETS, ...)` and
waits up to 100ms for the manager to take ownership. Without a real
manager, the data is lost when the Rust app exits / drops the
Clipboard struct. This daemon fills that gap.

Implementation notes:
- Uses python-xlib for X protocol access.
- Maintains a per-target byte cache. On SAVE_TARGETS we read TARGETS
  from the current CLIPBOARD owner, then read each data target, then
  claim CLIPBOARD ownership and serve those targets when paste apps
  ask for them.
- Designed to be small, dependency-light, and run as a daemon.
"""
from __future__ import annotations

import os
import select
import signal
import sys
import threading
import time

from Xlib import X, Xatom, display
from Xlib.protocol import event

LOG_PREFIX = "clipboard-manager"


def log(msg: str) -> None:
    print(f"[{LOG_PREFIX}] {msg}", flush=True)


# Targets we are willing to save and serve. Anything else is ignored.
TEXT_TARGETS = (
    "UTF8_STRING",
    "text/plain;charset=utf-8",
    "text/plain;charset=UTF-8",
    "text/plain",
    "STRING",
    "TEXT",
    "COMPOUND_TEXT",
)


class ClipboardManager:
    def __init__(self) -> None:
        self.dpy = display.Display()
        self.screen = self.dpy.screen()
        self.win = self.screen.root.create_window(
            -10, -10, 1, 1, 0, X.CopyFromParent,
            event_mask=X.PropertyChangeMask,
        )
        self.win.set_wm_name(LOG_PREFIX)
        self.win.set_wm_class(LOG_PREFIX, LOG_PREFIX)

        a = self.dpy.intern_atom
        self.A_CLIPBOARD = a("CLIPBOARD")
        self.A_CLIPBOARD_MANAGER = a("CLIPBOARD_MANAGER")
        self.A_SAVE_TARGETS = a("SAVE_TARGETS")
        self.A_TARGETS = a("TARGETS")
        self.A_MULTIPLE = a("MULTIPLE")
        self.A_TIMESTAMP = a("TIMESTAMP")
        self.A_INCR = a("INCR")
        self.A_ATOM = Xatom.ATOM
        self.A_INTEGER = Xatom.INTEGER

        self.text_target_atoms = {a(name): name for name in TEXT_TARGETS}

        # Cached data per target atom (bytes) and the time we last saved it.
        self.cache: dict[int, bytes] = {}
        self.cache_lock = threading.Lock()
        self.own_clipboard_timestamp = X.CurrentTime

        # Become the clipboard manager. Bail if someone else already is.
        existing = self.dpy.get_selection_owner(self.A_CLIPBOARD_MANAGER)
        if existing != X.NONE:
            log(f"CLIPBOARD_MANAGER already owned by 0x{existing.id:x}; exiting")
            sys.exit(1)
        self.win.set_selection_owner(self.A_CLIPBOARD_MANAGER, X.CurrentTime)
        self.dpy.flush()
        if self.dpy.get_selection_owner(self.A_CLIPBOARD_MANAGER).id != self.win.id:
            log("Failed to claim CLIPBOARD_MANAGER selection")
            sys.exit(1)
        log(f"Owning CLIPBOARD_MANAGER as 0x{self.win.id:x}")

    # ------------------------------------------------------------------
    # SAVE_TARGETS handling: read data from current CLIPBOARD owner.
    # ------------------------------------------------------------------
    def _read_property(self, target_atom: int, property_atom: int, requestor=None,
                       timeout: float = 0.5) -> bytes | None:
        """Issue ConvertSelection(CLIPBOARD, target_atom) and read the result.

        Reads from `requestor` window (defaults to self.win). Returns the
        property bytes, or None on timeout / error.
        """
        win = requestor or self.win
        win.delete_property(property_atom)
        win.convert_selection(
            self.A_CLIPBOARD, target_atom, property_atom, X.CurrentTime
        )
        self.dpy.flush()
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            self.dpy.pending_events()
            ev = self.dpy.next_event() if self.dpy.pending_events() else None
            if ev is None:
                # Wait up to remaining time for an event.
                fd = self.dpy.fileno()
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    break
                r, _, _ = select.select([fd], [], [], remaining)
                if not r:
                    break
                continue
            self._dispatch(ev)
            if isinstance(ev, event.SelectionNotify) and \
                    ev.requestor == win and \
                    ev.selection == self.A_CLIPBOARD and \
                    ev.target == target_atom:
                if ev.property == X.NONE:
                    return None
                prop = win.get_full_property(ev.property, X.AnyPropertyType)
                win.delete_property(ev.property)
                if prop is None:
                    return None
                if prop.property_type == self.A_INCR:
                    log("INCR transfer not supported, skipping")
                    return None
                return bytes(prop.value)
        return None

    def _snarf_clipboard(self) -> bool:
        """Read the current CLIPBOARD's TARGETS and cache useful target data."""
        owner = self.dpy.get_selection_owner(self.A_CLIPBOARD)
        if owner == X.NONE or owner.id == self.win.id:
            log("snarf: no foreign owner, nothing to do")
            return False
        prop_atom = self.dpy.intern_atom("CLIPBOARD_MANAGER_TMP")
        targets_bytes = self._read_property(self.A_TARGETS, prop_atom)
        if targets_bytes is None:
            log("snarf: failed to read TARGETS")
            return False
        # TARGETS is a list of 32-bit atoms.
        atoms = []
        for i in range(0, len(targets_bytes), 4):
            atoms.append(int.from_bytes(targets_bytes[i:i+4], "little"))
        new_cache: dict[int, bytes] = {}
        for atom in atoms:
            if atom not in self.text_target_atoms:
                continue
            data = self._read_property(atom, prop_atom)
            if data is not None:
                new_cache[atom] = data
        if not new_cache:
            log("snarf: no usable text targets; not taking ownership")
            return False
        with self.cache_lock:
            self.cache = new_cache
        # Take CLIPBOARD ownership ourselves.
        self.win.set_selection_owner(self.A_CLIPBOARD, X.CurrentTime)
        self.dpy.flush()
        sample = next(iter(new_cache.values()))[:80]
        log(f"snarf: took CLIPBOARD ownership; sample={sample!r}")
        return True

    # ------------------------------------------------------------------
    # SelectionRequest handling: serve cached data when others paste.
    # ------------------------------------------------------------------
    def _handle_selection_request(self, ev) -> None:
        # ev.selection: CLIPBOARD or CLIPBOARD_MANAGER
        # ev.target: what they want
        # ev.property: where to put the answer
        # ev.requestor: their window
        prop = ev.property if ev.property != X.NONE else ev.target
        success = False

        if ev.selection == self.A_CLIPBOARD_MANAGER and ev.target == self.A_SAVE_TARGETS:
            # Manager is being asked to save. Snarf the current clipboard owner.
            ok = self._snarf_clipboard()
            success = True  # Per spec, we ack regardless of whether anything was saved.
            # SAVE_TARGETS reply has property=None to indicate the conversion has no data.
            prop = X.NONE
            log(f"SAVE_TARGETS handled (snarfed={ok})")
        elif ev.selection == self.A_CLIPBOARD:
            if ev.target == self.A_TARGETS:
                with self.cache_lock:
                    cached = list(self.cache.keys())
                atoms = [self.A_TARGETS, self.A_TIMESTAMP] + cached
                data = b"".join(a.to_bytes(4, "little") for a in atoms)
                ev.requestor.change_property(prop, self.A_ATOM, 32, data)
                success = True
            elif ev.target == self.A_TIMESTAMP:
                ev.requestor.change_property(
                    prop, self.A_INTEGER, 32,
                    self.own_clipboard_timestamp.to_bytes(4, "little"),
                )
                success = True
            else:
                with self.cache_lock:
                    data = self.cache.get(ev.target)
                if data is not None:
                    ev.requestor.change_property(prop, ev.target, 8, data)
                    success = True
                else:
                    prop = X.NONE
        else:
            prop = X.NONE

        notify = event.SelectionNotify(
            time=ev.time,
            requestor=ev.requestor,
            selection=ev.selection,
            target=ev.target,
            property=prop if success else X.NONE,
        )
        ev.requestor.send_event(notify)
        self.dpy.flush()

    # ------------------------------------------------------------------
    # Event dispatcher.
    # ------------------------------------------------------------------
    def _dispatch(self, ev) -> None:
        if isinstance(ev, event.SelectionRequest):
            try:
                self._handle_selection_request(ev)
            except Exception as e:
                log(f"SelectionRequest error: {e}")
        elif isinstance(ev, event.SelectionClear):
            if ev.atom == self.A_CLIPBOARD:
                log("Lost CLIPBOARD ownership (someone else copied)")
                with self.cache_lock:
                    self.cache.clear()
            elif ev.atom == self.A_CLIPBOARD_MANAGER:
                log("Lost CLIPBOARD_MANAGER ownership; exiting")
                sys.exit(0)

    def run(self) -> None:
        log("Running event loop")
        while True:
            ev = self.dpy.next_event()
            self._dispatch(ev)


def main() -> int:
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
    ClipboardManager().run()
    return 0


if __name__ == "__main__":
    sys.exit(main())
