
## Installing software

Before installing any software, look into `mise/` to understand how to do it.

All software on this Fedora workstation is declared in the `mise` stow
package (`mise/.config/mise/` is symlinked to `~/.config/mise/`). Edit files
through the repo path, never through `~/.config/...`: in-place edits on the
symlink replace it with a plain file.

### Where a new tool goes

Use the first option, in this order, that ships the tool:

1. **rpm package from the already configured repos**: add it to
   `dnf_install` in `mise/.config/mise/dnf-packages.yml`, in the section that
   fits. It is installed by `task system:dnf`, not by mise. Packages to purge
   go in `dnf_remove`.

1. **Flatpak**: `mise/.config/mise/conf.d/bootstrap.toml`, under
   `[bootstrap.packages]`, as `"flatpak:<app.id>" = "latest"`. Flatpaks are
   the one place where `"latest"` is required: a version pin makes mise run
   `flatpak install id@version`, which flatpak rejects.

3. **mise tool**: `mise/.config/mise/config.toml`, under `[tools]`. Backend
   preference:

   - a short name from the mise registry (`yazi`, `gh`, `node`) when one
     exists (`mise registry | grep <name>` to check);
   - `github:<owner>/<repo>` for release binaries on GitHub;
   - `aqua:`, `cargo:`, `pipx:`, `npm:` or `gem:` when that is how upstream
     ships it (`npm:` installs through bun, see `[settings.npm]`);
   - `http:<name>` as a `[tools."http:<name>"]` table for a plain download URL.

   Use `asset_pattern`, `exe`, `version_prefix` or `postinstall` when the
   release assets need help. If the binary name differs from the repo, add a
   `[tool_alias]` entry and use the alias as the key.

### Third-party repos: only when explicitly asked

Never add a new dnf repo (copr, vendor `.repo` file, release rpm by URL)
unless the user explicitly says so. If a tool is only available that way,
stop and ask. When told to:

- put the `.repo` file under `mise/.config/mise/files/etc/yum.repos.d/` (the
  upstream file, or the one `dnf copr enable` would write, with a comment
  linking the source);
- register it in `mise/.config/mise/conf.d/bootstrap-repos.toml` under
  `[bootstrap.files]`;
- add the package to `dnf-packages.yml`.

Signing keys are not pre-imported; the repo's `gpgkey=` handles that.

### Supporting system setup

- **System config, services or files for a tool**: a dedicated
  `mise/.config/mise/conf.d/bootstrap-<name>.toml` (see
  `bootstrap-tailscale.toml`, `bootstrap-dnf-automatic.toml`) holding its
  `dnf:` package, `[bootstrap.files]`, `[bootstrap.directories]` and
  `[bootstrap.services]`. System files live under
  `mise/.config/mise/files/<absolute path>` and are referenced as
  `source = "../files/..."`. Managed files don't create their parent
  directories: declare them in `[bootstrap.directories]`.
- **Something none of the above can express** (e.g. flatpak remotes): an
  idempotent command in `[bootstrap.hooks.pre-packages]` (guard it, e.g.
  `rpm -q ... ||`), or a task in `.taskfiles/system.yml` with a `status:`
  check.

### Versions

- New `[tools]` entries in the global `config.toml` default to `"latest"`.
- Pin an exact version only when there is a reason (an upstream break, a
  backend that can't resolve `"latest"` such as `http:`), and say why in a
  comment next to it, as `fonts-hack` and `http:keymapp` do.
- Flatpaks always use `"latest"` (see above); `dnf:` packages follow the
  distro.

### Configuration for the tool

If the tool needs a config file, create a stow package for it at the repo
root (`<tool>/.config/<tool>/...`), as the `ku` and `yazi` packages do. Add
the config and the mise entry in the same commit.

### Applying changes

- `[tools]`: `cd ~ && mise install` (or `mise install <tool>`).
- Bootstrap entries: `mise bootstrap --yes`. Repo files have to land before
  their packages: `mise bootstrap files apply --yes` first.
- rpm lists: `task system:dnf`.

These touch the system (sudo, dnf, flatpak). Ask before running them unless
the user said to install.

### Conventions

- Comment the non-obvious: why a pin, why an asset pattern, why a hook,
  why a file mode. Existing comments show the expected density.
- Commits use conventional commits scoped to `mise`, e.g.
  `feat(mise): add <tool>`, with a short bullet list in the body.
- `.tool-versions` is intentionally empty; don't add tools there.
