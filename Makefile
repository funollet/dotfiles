STOW_PKGS := $(shell ls -I Taskfile.yml -I Makefile -I installers)


.PHONY: help
help:           ## Shows this message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: update
update: ## Update dotfiles.
	# Delete all symlinks. This deals with deleted config files.
	# Symlink files managed in this repo.
	for pkg in $(STOW_PKGS) ; do \
		stow -R $$pkg 2>&1 | sed '/^BUG in/d' ; \
	done
	stow --dir ~/code/wallapop/self-tools --target ~ -R scripts/ 2>&1 | sed '/^BUG in/d'


.PHONY: awesome-libs
awesome-libs:
	cd ~/.config/awesome/ && git clone https://github.com/deficient/volume-control.git
