#!/usr/bin/env bash
# ==============================================================================
# 🚀 zsh_tools.sh - Kompleksowy instalator nowoczesnego środowiska Zsh na macOS
# ==============================================================================
# Narzędzia: eza, fzf, zoxide, bat, glow, starship, zsh-syntax-highlighting, zsh-autosuggestions
# Działa zarówno na Apple Silicon (M1/M2/M3/M4) jak i na procesorach Intel.
# ==============================================================================

set -euo pipefail

# Kolory terminala
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}${BOLD}[OSTRZEŻENIE]${NC} $1"; }
error()   { echo -e "${RED}${BOLD}[BŁĄD]${NC} $1"; exit 1; }

echo -e "${BOLD}======================================================"
echo -e " 🚀 Instalator nowoczesnego środowiska Zsh dla macOS "
echo -e "======================================================${NC}"

# 1. Weryfikacja systemu operacyjnego
if [[ "$(uname -s)" != "Darwin" ]]; then
  error "Ten skrypt jest przeznaczony wyłącznie dla systemu macOS!"
fi

# 2. Weryfikacja lub instalacja Homebrew
info "Weryfikacja menedżera pakietów Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    warn "Homebrew nie został wykryty. Rozpoczynam instalację Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
fi

if ! command -v brew >/dev/null 2>&1; then
  error "Nie udało się zainicjalizować Homebrew. Upewnij się, że brew jest zainstalowane."
fi

BREW_PREFIX="$(brew --prefix)"
success "Homebrew gotowy (prefiks: ${BREW_PREFIX})"

# 3. Instalacja pakietów CLI
PACKAGES=(
  eza
  fzf
  zoxide
  bat
  glow
  starship
  zsh-syntax-highlighting
  zsh-autosuggestions
)

info "Instalacja narzędzi CLI przez Homebrew (${#PACKAGES[@]} pakietów)..."
NONINTERACTIVE=1 brew install "${PACKAGES[@]}"
success "Wszystkie pakiety zostały pomyślnie zainstalowane."

# 4. Kopia zapasowa ~/.zshrc
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
  BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$ZSHRC" "$BACKUP"
  info "Utworzono kopię zapasową: $BACKUP"
else
  touch "$ZSHRC"
  info "Utworzono nowy plik $ZSHRC"
fi

# 5. Przygotowanie bloku konfiguracyjnego dla Zsh
CONFIG_MARKER_START="# >>> modern-zsh-tools >>>"
CONFIG_MARKER_END="# <<< modern-zsh-tools <<<"

CONFIG_CONTENT="${CONFIG_MARKER_START}
# ==========================================
# Terminal & Zsh UI Enhancements
# ==========================================

# 1. Historia i opcje powłoki (Quality of Life)
HISTFILE=\"\$HOME/.zsh_history\"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Zapisuj znacznik czasu wykonania komend
setopt SHARE_HISTORY             # Współdziel historię na żywo między wszystkimi kartami terminala
setopt HIST_EXPIRE_DUPS_FIRST    # Usuwaj najpierw duplikaty przy zapełnieniu
setopt HIST_IGNORE_ALL_DUPS      # Usuwaj starsze duplikaty, zachowując najnowszą pozycję
setopt HIST_IGNORE_SPACE         # Nie zapisuj komend zaczynających się od spacji (np. sekrety)
setopt HIST_SAVE_NO_DUPS         # Nie duplikuj wpisów w pliku historii
setopt AUTO_CD                   # Wpisanie samej nazwy folderu (np. \"..\" lub \"Downloads\") działa jak cd

# Inteligentne wyszukiwanie w historii strzałkami ↑ / ↓ (wg wpisanego prefiksu)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

# 2. Narzędzia nowoczesnego CLI (eza, bat, glow, fzf, zoxide)
if command -v eza >/dev/null 2>&1; then
  alias ls=\"eza --icons --group-directories-first\"
  alias l=\"eza -lh --icons --group-directories-first\"
  alias ll=\"eza -lah --icons --group-directories-first --git\"
  alias tree=\"eza --tree --icons\"
fi

if command -v bat >/dev/null 2>&1; then
  alias cat=\"bat --paging=auto --style=plain\"
fi

if command -v glow >/dev/null 2>&1; then
  alias md=\"glow -p\"
fi

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS=\"--height 40% --layout=reverse --border --inline-info\"
  if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS=\"--preview 'bat --color=always --line-range :50 {} 2>/dev/null || cat {} 2>/dev/null'\"
  fi
fi

if command -v zoxide >/dev/null 2>&1; then
  eval \"\$(zoxide init zsh)\"
fi

# 3. Autouzupełnianie z kolorowaniem typów plików (klawisz Tab)
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Kolorowanie plików w menu podpowiedzi Tab
zstyle ':completion:*' list-colors \\
  'di=34;1' \\
  'ln=36;1' \\
  'so=32' \\
  'pi=33' \\
  'ex=32;1' \\
  'bd=46;34' \\
  'cd=43;34' \\
  '*.tar=31;1' '*.tgz=31;1' '*.zip=31;1' '*.gz=31;1' '*.bz2=31;1' '*.7z=31;1' \\
  '*.jpg=35;1' '*.png=35;1' '*.gif=35;1' '*.webp=35;1' '*.svg=35;1' \\
  '*.mp4=35' '*.mkv=35' '*.mov=35' '*.mp3=35' '*.wav=35' \\
  '*.pdf=33;1' '*.md=36' '*.json=33' '*.yaml=33' '*.yml=33'

# 4. Nowoczesny prompt (Starship)
if [[ \"\$TERM\" != \"dumb\" ]] && command -v starship >/dev/null 2>&1; then
  eval \"\$(starship init zsh)\"
fi

# 5. Wtyczki Zsh (autosuggestions najpierw, syntax-highlighting ZAWSZE na samym końcu)
if [ -f \"${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh\" ]; then
  source \"${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh\"
fi

if [ -f \"${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\" ]; then
  source \"${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\"
fi
${CONFIG_MARKER_END}"

# 6. Idempotentne wstawienie konfiguracji do ~/.zshrc
info "Konfiguracja pliku ~/.zshrc..."

if grep -qF "$CONFIG_MARKER_START" "$ZSHRC"; then
  info "Wykryto wcześniejszą konfigurację modern-zsh-tools. Aktualizuję blok..."
  # Usuwamy stary blok i dodajemy nowy
  sed -i '' "/${CONFIG_MARKER_START}/,/${CONFIG_MARKER_END}/d" "$ZSHRC"
  echo "$CONFIG_CONTENT" >> "$ZSHRC"
else
  # Jeśli w zshrc były wcześniejsze pojedyncze wpisy bez markerów, nie dublujemy
  echo "" >> "$ZSHRC"
  echo "$CONFIG_CONTENT" >> "$ZSHRC"
fi

# 7. Weryfikacja składni pliku ~/.zshrc
if zsh -n "$ZSHRC"; then
  success "Składnia ~/.zshrc jest w 100% poprawna."
else
  error "Wykryto błąd składni w ~/.zshrc! Przywróć plik z kopii zapasowej."
fi

echo -e "\n${GREEN}${BOLD}🎉 Instalacja zakończona sukcesem!${NC}"
echo -e "Aby aktywować zmiany, wpisz w bieżącym oknie:"
echo -e "  ${BOLD}source ~/.zshrc${NC}"
echo -e "(lub po prostu otwórz nową kartę terminala).\n"
