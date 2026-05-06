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
	nvim --headless -u NONE -l tests/smoke.lua
