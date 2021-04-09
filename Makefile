STOW_PKGS := $(shell ls -I Taskfile.yml -I Makefile -I installers)


.PHONY: help
help:           ## Shows this message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: update
update: ## Update dotfiles.
	# Delete all symlinks. This deals with deleted config files.
	# Symlink files managed in this repo.
	echo $(STOW_PKGS) | xargs -n1 stow -R
	stow --dir ~/code/wallapop/self-tools --target ~ -R scripts/


.PHONY: awesome-libs
awesome-libs:
	cd ~/.config/awesome/ && git clone https://github.com/deficient/volume-control.git
