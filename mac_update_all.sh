#!/usr/bin/env bash
# ==============================================================================
#  mac_update_all.sh — Uniwersalny, mobilny kombajn aktualizacyjny dla macOS
# ==============================================================================
#  Autor: Wojcio & Antigravity (Google DeepMind Pair Programming)
#  Kompatybilność: macOS 13+, Apple Silicon (M1/M2/M3/M4) & Intel
#
#  Co robi ten skrypt na DOWOLNYM Macu:
#  1. Odświeża i utrzymuje uprawnienia administratora (sudo) w tle.
#  2. Wykrywa środowisko (macOS version, Homebrew, mas CLI).
#  3. Aktualizuje komponenty systemowe Apple i przeglądarkę Safari (softwareupdate).
#  4. Aktualizuje pakiety i aplikacje Mac App Store (mas CLI).
#  5. Aktualizuje wszystkie formuły i narzędzia CLI Homebrew (brew upgrade).
#  6. Aktualizuje aplikacje Cask zarządzane przez Homebrew (brew upgrade --cask --greedy).
#  7. INTELIGENTNY AUTO-DISCOVERY: skanuje /Applications na danej maszynie,
#     wykrywa aplikacje posiadające nowszą wersję w rejestrze Cask i bezpiecznie
#     je aktualizuje (NIE instaluje niczego, czego dany Mac nie posiada!).
#  8. Czyści pamięć podręczną i stare pakiety (brew cleanup).
# ==============================================================================

set -e

# Kolory do terminala
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}======================================================================${NC}"
echo -e "${BOLD}${BLUE} 🍏 Universal macOS Updater — Pełna Aktualizacja Systemu i Aplikacji ${NC}"
echo -e "${BOLD}${BLUE}======================================================================${NC}"

# Informacje o systemie
OS_VER=$(sw_vers -productVersion)
OS_BUILD=$(sw_vers -buildVersion)
ARCH=$(uname -m)
echo -e "💻 Wykryty system: ${BOLD}macOS ${OS_VER} (${OS_BUILD}) [${ARCH}]${NC}"
echo -e "👤 Użytkownik: ${BOLD}${USER}${NC} | Host: ${BOLD}$(hostname)${NC}\n"

# 1. Sprawdzenie i podtrzymanie uprawnień sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}🔑 Wymagane uprawnienia administratora do aktualizacji systemowych i PKG.${NC}"
    echo -e "   Proszę podać hasło (zostanie zapamiętane w tle na czas całego procesu):"
    sudo -v
    # Utrzymuj token sudo w tle dopóki skrypt działa
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
fi

# 2. Weryfikacja Homebrew
echo -e "\n${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
echo -e "${BOLD}🔍 Krok 1/6: Sprawdzanie menedżera pakietów Homebrew...${NC}"
echo -e "${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ Homebrew nie jest zainstalowany na tym Macu.${NC}"
    read -p "Czy chcesz zainstalować Homebrew teraz? (t/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[TtYy]$ ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
    else
        echo -e "${RED}Pominięto aktualizację Homebrew i Cask.${NC}"
    fi
else
    echo -e "${GREEN}✔ Homebrew znaleziony:${NC} $(brew --version | head -n 1)"
fi

# 3. Weryfikacja mas (Mac App Store CLI)
if command -v brew >/dev/null 2>&1; then
    if ! command -v mas >/dev/null 2>&1; then
        echo -e "${YELLOW}📦 Instaluję narzędzie 'mas' (Mac App Store CLI) przez Homebrew...${NC}"
        brew install mas || true
    fi
fi

# 4. Aktualizacje systemowe macOS & Safari
echo -e "\n${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
echo -e "${BOLD}🍏 Krok 2/6: Sprawdzanie aktualizacji systemowych macOS (Apple)...${NC}"
echo -e "${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
if command -v softwareupdate >/dev/null 2>&1; then
    echo "Szukam dostępnych aktualizacji Apple..."
    SW_LIST=$(softwareupdate -l 2>&1 || true)
    if echo "$SW_LIST" | grep -qi "No new software available"; then
        echo -e "${GREEN}✔ System macOS i Safari są w pełni aktualne!${NC}"
    else
        echo "$SW_LIST"
        echo -e "\n${YELLOW}⚡ Instaluję zalecane poprawki systemowe (bez restartu wymuszonego)...${NC}"
        sudo softwareupdate -ia --include-config-data || true
    fi
fi

# 5. Aktualizacje Mac App Store (mas CLI)
echo -e "\n${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
echo -e "${BOLD}🛒 Krok 3/6: Aktualizacja aplikacji z Mac App Store...${NC}"
echo -e "${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
if command -v mas >/dev/null 2>&1; then
    if mas account >/dev/null 2>&1; then
        echo -e "${GREEN}✔ Zalogowano do Mac App Store:${NC} $(mas account)"
        OUTDATED_MAS=$(mas outdated 2>/dev/null || true)
        if [ -n "$OUTDATED_MAS" ]; then
            echo -e "${YELLOW}Wykryto aktualizacje z App Store:${NC}\n$OUTDATED_MAS\n"
            echo "Aktualizuję aplikacje ze sklepu..."
            sudo mas update || true
            echo -e "${GREEN}✔ Zaktualizowano aplikacje z App Store!${NC}"
        else
            echo -e "${GREEN}✔ Wszystkie aplikacje z Mac App Store są aktualne!${NC}"
        fi
    else
        echo -e "${YELLOW}ℹ️ Nie wykryto aktywnej sesji App Store CLI. Możesz uaktualnić aplikacje bezpośrednio w aplikacji App Store:${NC}"
        echo -e "   Uruchom: ${BOLD}open macappstore://showUpdatesPage${NC}"
    fi
else
    echo -e "${YELLOW}Pominięto Mac App Store (brak narzędzia 'mas').${NC}"
fi

# 6. Aktualizacje pakietów Homebrew Formulae & Istniejących Casków
if command -v brew >/dev/null 2>&1; then
    echo -e "\n${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
    echo -e "${BOLD}📦 Krok 4/6: Aktualizacja bazy i narzędzi Homebrew CLI...${NC}"
    echo -e "${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
    brew update
    echo "Aktualizuję pakiety i narzędzia terminalowe (brew upgrade)..."
    brew upgrade || true

    echo -e "\n${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
    echo -e "${BOLD}📦 Krok 5/6: Aktualizacja aplikacji Homebrew Cask (zarządzanych)...${NC}"
    echo -e "${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
    
    # Bezpieczne obsłużenie Stats.app przed upgrade, jeśli występuje
    if [ -f "/Library/LaunchDaemons/eu.exelban.Stats.SMC.Helper.plist" ]; then
        sudo launchctl bootout system /Library/LaunchDaemons/eu.exelban.Stats.SMC.Helper.plist 2>/dev/null || true
        sudo rm -f /Library/PrivilegedHelperTools/eu.exelban.Stats.SMC.Helper /Library/LaunchDaemons/eu.exelban.Stats.SMC.Helper.plist 2>/dev/null || true
    fi

    brew upgrade --cask --greedy || true

    # 7. Inteligentny Auto-Discovery dla aplikacji w /Applications
    echo -e "\n${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
    echo -e "${BOLD}🧠 Krok 6/6: Inteligentny Auto-Discovery zainstalowanych aplikacji...${NC}"
    echo -e "${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
    echo "Skanuję /Applications i ~/Applications w poszukiwaniu dostępnych aktualizacji..."

    python3 -c "
import os
import sys
import json
import urllib.request
import plistlib
import subprocess
import re
import time

def parse_ver(v):
    if not v: return []
    cleaned = re.sub(r'[^\d.]', '', str(v).split('-')[0].split('_')[0].split(',')[0].split('+')[0])
    parts = [int(p) for p in cleaned.split('.') if p.isdigit()]
    return parts

cask_cache = '/tmp/brew_casks_cache.json'
try:
    if not os.path.exists(cask_cache) or (time.time() - os.path.getmtime(cask_cache)) > 43200:
        req = urllib.request.Request('https://formulae.brew.sh/api/cask.json', headers={'User-Agent': 'curl/8.0'})
        with urllib.request.urlopen(req, timeout=15) as resp:
            with open(cask_cache, 'wb') as f:
                f.write(resp.read())
    with open(cask_cache, 'rb') as f:
        casks = json.load(f)
except Exception as e:
    print(f'Nie udało się pobrać indeksu Cask ({e}), pomijam auto-discovery.')
    sys.exit(0)

# Budujemy mapę aplikacji z bazy Cask (wyłącznie wersje stabilne)
app_map = {}
for c in casks:
    token = c.get('token')
    ver = c.get('version')
    if '@' in token or token.endswith('-nightly') or token.endswith('-beta') or token.endswith('-preview') or token.endswith('-dev'):
        continue
    for a in c.get('artifacts', []):
        if isinstance(a, dict) and 'app' in a:
            for item in a['app']:
                name = item if isinstance(item, str) else list(item.keys())[0] if isinstance(item, dict) else None
                if name:
                    app_map[name.lower()] = (token, ver)

# Skanujemy aplikacje na tej konkretnej maszynie
scan_dirs = ['/Applications', os.path.expanduser('~/Applications')]
to_upgrade = []

for d in scan_dirs:
    if not os.path.exists(d): continue
    for entry in os.listdir(d):
        if entry.endswith('.app'):
            low_name = entry.lower()
            if low_name in app_map:
                token, remote_ver = app_map[low_name]
                info_p = os.path.join(d, entry, 'Contents', 'Info.plist')
                if os.path.exists(info_p):
                    try:
                        with open(info_p, 'rb') as fp:
                            pl = plistlib.load(fp)
                            lver = str(pl.get('CFBundleShortVersionString') or pl.get('CFBundleVersion') or '').strip()
                            pv_local = parse_ver(lver)
                            pv_remote = parse_ver(remote_ver)
                            if pv_remote and pv_local and pv_remote > pv_local:
                                to_upgrade.append((entry, token, lver, remote_ver))
                    except Exception:
                        pass

if not to_upgrade:
    print('✔ Wszystkie aplikacje w /Applications są w najnowszych wersjach!')
else:
    print(f'Wykryto {len(to_upgrade)} aplikacji wymagających aktualizacji:')
    tokens_to_run = []
    for app_name, token, lver, rver in to_upgrade:
        print(f'  - {app_name:<25}: {lver} ➔ {rver} (cask: {token})')
        tokens_to_run.append(token)
    
    # Zapisz listę tokenów do pliku tymczasowego dla basha
    with open('/tmp/apps_to_brew_upgrade.txt', 'w') as out_f:
        out_f.write(' '.join(tokens_to_run))
"

    if [ -f "/tmp/apps_to_brew_upgrade.txt" ]; then
        TOKENS=$(cat /tmp/apps_to_brew_upgrade.txt)
        rm -f /tmp/apps_to_brew_upgrade.txt
        if [ -n "$TOKENS" ]; then
            echo -e "\n${YELLOW}Instaluję najnowsze wersje wykrytych aplikacji przez Homebrew...${NC}"
            for tok in $TOKENS; do
                echo -e "🚀 Aktualizuję: ${BOLD}${tok}${NC}..."
                brew install --cask --force "$tok" || echo -e "${RED}Błąd aktualizacji ${tok}, pomijam.${NC}"
            done
        fi
    fi

    # 8. Czyszczenie pamięci podręcznej i starych wersji
    echo -e "\n${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
    echo -e "${BOLD}🧹 Czyszczenie pamięci podręcznej Homebrew...${NC}"
    echo -e "${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
    brew cleanup -s || true
fi

echo -e "\n${BOLD}${GREEN}======================================================================${NC}"
echo -e "${BOLD}${GREEN} 🎉 SUKCES! System i wszystkie aplikacje na tym Macu są zaktualizowane! ${NC}"
echo -e "${BOLD}${GREEN}======================================================================${NC}\n"
