

# Update dotfiles.
update:
    # Delete all symlinks. This deals with deleted config files.
    # Symlink files managed in this repo.
    STOW_PKGS=`ls -I justfile -I Taskfile.yml -I Makefile -I installers` && \
    for pkg in ${STOW_PKGS} ; do \
        stow -R $pkg 2>&1 | sed '/^BUG in/d' ; \
    done
    # stow --dir ~/code/wallapop/self-tools --target ~ -R scripts/ 2>&1 | sed '/^BUG in/d'


awesome-libs:
    cd ~/.config/awesome/ && git clone https://github.com/deficient/volume-control.git

kde-kwin-reload:
    qdbus org.kde.KWin /KWin reconfigure
  
kde-shortcuts-reload:
    kquitapp5 kglobalaccel && sleep 2s && kglobalaccel5 &
