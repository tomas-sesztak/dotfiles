SHELL := bash

SH_FILES := $(sort setup.sh $(wildcard tests/*.sh) $(shell git ls-files '*.sh' 'stow_modules/tmux/.tmux/scripts/*'))
ZSH_FILES := $(shell git ls-files '*.zsh')
JSON_FILES := $(shell git ls-files '*.json')
TOML_FILES := $(shell git ls-files '*.toml')

define require
@for tool in $(1); do \
	command -v $$tool >/dev/null || { echo "missing tool: $$tool" >&2; exit 1; }; \
done
endef

# runs every script even after a failure
define run_tests
@rc=0; for name in $(1); do bash tests/$$name.sh || rc=1; done; exit $$rc
endef

.PHONY: test lint unit integration

test: lint unit integration

lint:
	$(call require,zsh bash shellcheck jq python3)
	@for f in $(ZSH_FILES); do zsh -n "$$f" || exit 1; done
	@for f in $(SH_FILES); do bash -n "$$f" || exit 1; done
	@shellcheck -x -P SCRIPTDIR $(SH_FILES)
	@for f in $(JSON_FILES); do jq empty "$$f" || exit 1; done
	@python3 -c 'import sys, tomllib; [tomllib.load(open(f, "rb")) for f in sys.argv[1:]]' $(TOML_FILES)
	@echo "lint: ok"

unit:
	$(call require,bash zsh jq)
	$(call run_tests,guard sanitize hooks)

integration:
	$(call require,bash zsh git jq stow tmux nvim vim)
	$(call run_tests,setup-script tmux editors)
