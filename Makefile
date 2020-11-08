
STOW_PKGS := $(shell ls -I Taskfile.yml -I Makefile -I installers)

help:           ## Shows this message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


update: ## Update dotfiles.
	git pull
	# Delete all symlinks. This deals with deleted config files.
	# Symlink files managed in this repo.
	for pkg in $(STOW_PKGS) ; do \
		stow -D $$pkg ; \
		stow -S $$pkg ; \
	done


awesome-libs:
	cd ~/.config/awesome/ && git clone https://github.com/deficient/volume-control.git


.PHONY: help update awesome-libs
