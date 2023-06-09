SHELL := /bin/bash
# Package bundles
DOTFILES_DIR = $(CURDIR)
PKG_DIR = $(DOTFILES_DIR)/modules
ALL_PKGS = $(sort $(notdir $(realpath $(wildcard modules/*/))))
# LOCAL_PKGS = $(sort $(notdir $(wildcard ./local*)))
DEFAULT_PKGS = fzf git github ssh starship utility vim zoxide zsh


# XDG directories
XDG_CONFIG_HOME := $(HOME)/.config
XDG_DATA_HOME := $(HOME)/.local/share
XDG_CACHE_HOME := $(HOME)/.cache
# Non standard
XDG_BIN_HOME := $(HOME)/.local/bin
XDG_LIB_HOME := $(HOME)/.local/lib

# macOS specific settings
ifeq ($(shell uname), Darwin)
	DEFAULT_PKGS := $(DEFAULT_PKGS) macos homebrew
endif

# Linux specific settings
ifeq ($(shell uname), Linux)
	DEFAULT_PKGS := $(DEFAULT_PKGS)
endif

all: setup prepare-dirs link

shellcheck:
	@shellcheck $$(find . -type f -path '*/bin/**' ! -name '*.*')
	@shellcheck $$(find . -name '*.sh')

shfmt:
	@shfmt -i 2 -ci -l $$(find . -type f -path '*/bin/**' ! -name '*.*')
	@shfmt -i 2 -ci -l $$(find . -name '*.sh')

lint: shellcheck shfmt

setup:
	@stow -t $(HOME) -d modules -S _core

prepare-dirs:
	@mkdir -p $(DOTFILES_DIR)
# TODO: consider local package
# @ln -sf $(DOTFILES_DIR)/local $(PKG_DIR)
	@mkdir -p $(HOME)/.ssh/config.d
	@mkdir -p $(XDG_CONFIG_HOME)/profile.d
	@mkdir -p $(XDG_CONFIG_HOME)/shell.d
	@mkdir -p $(XDG_CONFIG_HOME)/git
	@mkdir -p $(XDG_CONFIG_HOME)/less
	@mkdir -p $(XDG_DATA_HOME)/zsh
	@mkdir -p $(XDG_CACHE_HOME)/less
	@mkdir -p $(XDG_BIN_HOME)
	@mkdir -p $(XDG_LIB_HOME)
ifeq ($(shell uname), Darwin)
	@mkdir -p $(XDG_CONFIG_HOME)/homebrew
endif

link: setup prepare-dirs
	@stow -t $(HOME) -d $(PKG_DIR) -S $(ALL_PKGS)

unlink:
	@stow -t $(HOME) -d $(PKG_DIR) -D $(filter-out stow,$(ALL_PKGS))

.PHONY: .chklink
chklink:
	@echo "\n--- Default package files currently unlinked ---\n"
	@stow -n -v -t $(HOME) -d $(PKG_DIR) -S $(ALL_PKGS)
	@echo "\n--- Bogus links ---\n"
	@chkstow -a -b -t $(XDG_CONFIG_HOME)
	@chkstow -a -b -t $(XDG_DATA_HOME)
	@chkstow -a -b -t $(XDG_BIN_HOME)
	@chkstow -a -b -t $(XDG_LIB_HOME)

.PHONY: list-pkgs
list-pkgs:
	@echo $(ALL_PKGS:/=)

.PHONY: list-makefiles
list-makefiles:
	@echo $(PKG_MAKEFILES)

.PHONY: $(PKG_MAKEFILES)
$(PKG_MAKEFILES):
	@echo $@
	@$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: .DEFAULT
.DEFAULT:
	@for dir in $(PKG_MAKEFILES); do \
		$(MAKE) -C $$dir $(MAKECMDGOALS); \
	done