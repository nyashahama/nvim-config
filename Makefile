.PHONY: bootstrap check doctor dry-run install test

check:
	./bootstrap.sh --check
	./scripts/.local/bin/dotfiles-doctor
	$(MAKE) test

dry-run:
	./install.sh --dry-run

bootstrap:
	./bootstrap.sh --install

install:
	./install.sh --apply

doctor:
	./scripts/.local/bin/dotfiles-doctor

test:
	bash tests/dotfiles_layout.sh
	bash tests/vscode_config.sh
	bash tests/dev_init.sh
	bash tests/workstation_workflow.sh
	bash tests/neovim_primary.sh
	bash tests/shell_startup.sh
	nvim --headless -u NONE -l tests/smoke.lua
