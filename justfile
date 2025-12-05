

# Update dotfiles.
update:
    # Delete all symlinks. This deals with deleted config files.
    # Symlink files managed in this repo.
    STOW_PKGS=`ls -I justfile -I Taskfile.yml -I Makefile -I installers` && \
    for pkg in ${STOW_PKGS} ; do \
        stow -R $pkg 2>&1 \
    ; done
    stow --target ~/bin --dir ~/code/user-land/ packaged

systemctl:
  systemctl --user daemon-reload
  systemctl --user enable fusuma.service
  systemctl --user enable ulauncher.service
