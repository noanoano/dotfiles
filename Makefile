# macOS の BSD make
SHELL := /bin/sh
DOTFILES_DIR ?= $(HOME)/dotfiles
PACKAGES ?= fish starship alacritty nvim tmux git

say  = printf '\033[1;32m==>\033[0m %s\n' "$(1)"
warn = printf '\033[1;33m[WARN]\033[0m %s\n' "$(1)"

.PHONY: help all bootstrap brew stow restow unlink volta node fish_shell doctor

help: ## ターゲット一覧
	@awk 'BEGIN{FS=":.*##"; print "Targets:"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-14s %s\n", $$1, $$2}' Makefile

all: bootstrap brew stow volta node fish_shell ## ひと通り実行

bootstrap: ## Homebrew を用意
	@{ command -v brew >/dev/null 2>&1 \
		|| ( $(call say,"Homebrew not found. Installing..."); \
		     /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"); }

brew: ## Brewfile を適用
	@{ [ -f "$(DOTFILES_DIR)/Brewfile" ] \
		&& ( $(call say,"Running brew bundle..."); brew bundle -v --file="$(DOTFILES_DIR)/Brewfile" || $(call warn,"brew bundle had issues. Check output above.") ) \
		|| $(call warn,"Brewfile not found at $(DOTFILES_DIR)/Brewfile."); }

stow: ## シンボリックリンク配置
	@mkdir -p "$(HOME)/.config"
	@command -v stow >/dev/null 2>&1 \
		&& ( $(call say,"Stowing: $(PACKAGES)"); stow -v -d "$(DOTFILES_DIR)/packages" -t "$(HOME)" $(PACKAGES) || true ) \
		|| $(call warn,"GNU stow is not installed. Skipping stow.")

restow: ## 既存リンクの再配置（衝突時の復旧）
	@command -v stow >/dev/null 2>&1 && stow -R -v -d "$(DOTFILES_DIR)/packages" -t "$(HOME)" $(PACKAGES) || true

unlink: ## すべてのリンク解除
	@command -v stow >/dev/null 2>&1 && stow -D -v -d "$(DOTFILES_DIR)/packages" -t "$(HOME)" $(PACKAGES) || true

volta: ## Volta を導入
	@{ command -v volta >/dev/null 2>&1 \
		|| ( printf '\033[1;32m==>\033[0m %s\n' "Installing Volta..."; \
		     curl -fsSL https://get.volta.sh | bash ); }
	@VOLTA_BIN="$(HOME)/.volta/bin/volta"; [ -x "$$VOLTA_BIN" ] || exit 0; \
	 "$$VOLTA_BIN" --version >/dev/null 2>&1 || true

node: volta ## Node を Volta で既定化
	@VOLTA_BIN="$(HOME)/.volta/bin/volta"; \
	if ! "$$VOLTA_BIN" which node >/dev/null 2>&1; then \
	  printf '\033[1;32m==>\033[0m %s\n' "Installing Node.js (latest via Volta as default)..."; \
	  "$$VOLTA_BIN" install node@latest; \
	else \
	  v="$$(node -v 2>/dev/null || true)"; \
	  printf '\033[1;32m==>\033[0m %s\n' "Node.js already managed by Volta: $$v"; \
	fi

fish_shell: ## fish をログインシェルに
	@BREW_PREFIX="$$(brew --prefix 2>/dev/null || true)"; \
	[ -n "$$BREW_PREFIX" ] || BREW_PREFIX="/opt/homebrew"; \
	FISH_PATH="$$BREW_PREFIX/bin/fish"; \
	if [ ! -x "$$FISH_PATH" ]; then \
	  printf '\033[1;33m[WARN]\033[0m %s\n' "fish not found at $$FISH_PATH. Did 'brew install fish' succeed?"; exit 0; \
	fi; \
	if ! grep -qx "$$FISH_PATH" /etc/shells 2>/dev/null; then \
	  printf '\033[1;32m==>\033[0m %s\n' "Adding $$FISH_PATH to /etc/shells (requires sudo)..."; \
	  echo "$$FISH_PATH" | sudo tee -a /etc/shells >/dev/null || true; \
	fi; \
	CURRENT_SHELL="$$(dscl . -read ~ UserShell 2>/dev/null | awk '{print $$2}' || echo "$$SHELL")"; \
	if [ "$$CURRENT_SHELL" = "$$FISH_PATH" ]; then \
	  printf '\033[1;32m==>\033[0m %s\n' "Login shell already fish ($$FISH_PATH)."; \
	else \
	  printf '\033[1;32m==>\033[0m %s\n' "Changing login shell to $$FISH_PATH..."; \
	  chsh -s "$$FISH_PATH" || printf '\033[1;33m[WARN]\033[0m %s\n' "chsh failed. Run: chsh -s $$FISH_PATH"; \
	fi

doctor: ## 環境チェック
	@echo "brew: $$(command -v brew || echo not found)"; \
	echo "stow: $$(command -v stow || echo not found)"; \
	echo "volta: $$(command -v volta || echo not found)"; \
	echo "node: $$(command -v node || echo not found)"; \
	echo "fish: $$(command -v fish || echo not found)"

