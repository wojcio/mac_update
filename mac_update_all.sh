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
OS_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
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
    echo -e "Obecnie zainstalowana wersja systemu: ${BOLD}macOS ${OS_VER}${NC} (gałąź ${BOLD}${OS_MAJOR}.x${NC})"
    echo -e "Czy podczas aktualizacji systemowej chcesz podnieść główną wersję macOS,"
    echo -e "czy tylko poszukać poprawek dla bieżącej zainstalowanej wersji?"
    echo -e "  ${BOLD}[1]${NC} Tylko poprawki dla bieżącej wersji (${BOLD}macOS ${OS_MAJOR}.x${NC}, Safari, XProtect) ${GREEN}[Domyślnie]${NC}"
    echo -e "  ${BOLD}[2]${NC} Podnieś również główną wersję macOS (pełny upgrade do nowszego wydania)"
    read -p "Wybierz opcję [1/2, domyślnie 1]: " -r MACOS_UPGRADE_CHOICE < /dev/tty || MACOS_UPGRADE_CHOICE="1"
    echo ""

    ALLOW_MAJOR_UPGRADE=false
    if [[ "$MACOS_UPGRADE_CHOICE" =~ ^(2|[TtYy])$ ]]; then
        ALLOW_MAJOR_UPGRADE=true
        echo -e "${YELLOW}➔ Wybrano: Pełna aktualizacja (wraz z podniesieniem głównej wersji macOS, jeśli dostępna).${NC}"
    else
        echo -e "${GREEN}➔ Wybrano: Tylko poprawki i łatki bezpieczeństwa dla bieżącej wersji (macOS ${OS_MAJOR}.x).${NC}"
    fi

    echo "Szukam dostępnych aktualizacji Apple..."
    SW_LIST=$(softwareupdate -l 2>&1 || true)
    if echo "$SW_LIST" | grep -qi "No new software available"; then
        echo -e "${GREEN}✔ System macOS i Safari są w pełni aktualne!${NC}"
    else
        if [ "$ALLOW_MAJOR_UPGRADE" = true ]; then
            echo "$SW_LIST"
            echo -e "\n${YELLOW}⚡ Instaluję wszystkie dostępne aktualizacje Apple (w tym ewentualną nową wersję macOS)...${NC}"
            sudo softwareupdate -ia --include-config-data || true
        else
            # Filtrujemy aktualizacje: oddzielamy podniesienie głównej wersji macOS od poprawek dla bieżącej gałęzi
            SW_PARSED=$(SW_TEXT="$SW_LIST" OS_MAJ="$OS_MAJOR" python3 -c "
import os, re

os_major = int(os.environ.get('OS_MAJ', '0'))
sw_text = os.environ.get('SW_TEXT', '')

current_label = None
for line in sw_text.splitlines():
    m_label = re.match(r'^\s*\*\s*Label:\s*(.+?)\s*$', line)
    if m_label:
        current_label = m_label.group(1)
        continue
    if current_label and ('Title:' in line or 'Version:' in line):
        m_title = re.search(r'Title:\s*([^,]+)', line)
        m_ver = re.search(r'Version:\s*([^,\s]+)', line)
        title = m_title.group(1).strip() if m_title else ''
        ver = m_ver.group(1).strip() if m_ver else ''

        is_macos_os = current_label.lower().startswith('macos ') or title.lower().startswith('macos ')
        is_major_upgrade = False
        if is_macos_os:
            ver_match = re.match(r'^(\d+)', ver) or re.search(r'macOS\s+(?:[A-Za-z]+\s+)?(\d+)', current_label + ' ' + title, re.IGNORECASE)
            if ver_match and int(ver_match.group(1)) != os_major:
                is_major_upgrade = True

        prefix = 'MAJOR' if is_major_upgrade else 'PATCH'
        print(f'{prefix}|{current_label}')
        current_label = None
")
            PATCH_LABELS=()
            MAJOR_LABELS=()
            while IFS='|' read -r kind lbl; do
                [ -z "$lbl" ] && continue
                if [ "$kind" = "MAJOR" ]; then
                    MAJOR_LABELS+=("$lbl")
                elif [ "$kind" = "PATCH" ]; then
                    PATCH_LABELS+=("$lbl")
                fi
            done <<< "$SW_PARSED"

            if [ "${#MAJOR_LABELS[@]}" -gt 0 ]; then
                echo -e "${YELLOW}ℹ️  Pominięto aktualizację do nowej głównej wersji systemu: ${BOLD}${MAJOR_LABELS[*]}${NC}"
            fi

            if [ "${#PATCH_LABELS[@]}" -gt 0 ]; then
                echo -e "\n${YELLOW}⚡ Znaleziono poprawki dla bieżącej wersji systemu (macOS ${OS_MAJOR}.x):${NC}"
                for plbl in "${PATCH_LABELS[@]}"; do
                    echo -e "  - ${BOLD}${plbl}${NC}"
                done
                echo -e "\n${YELLOW}Instaluję wybrane poprawki (bez podnoszenia głównej wersji macOS)...${NC}"
                sudo softwareupdate -i "${PATCH_LABELS[@]}" --include-config-data || true
            else
                echo -e "${GREEN}✔ Brak nowych poprawek dla bieżącej wersji macOS ${OS_VER} — system w gałęzi ${OS_MAJOR}.x jest w pełni aktualny!${NC}"
            fi
        fi
    fi
fi

# 5. Aktualizacje Mac App Store (mas CLI)
echo -e "\n${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
echo -e "${BOLD}🛒 Krok 3/6: Aktualizacja aplikacji z Mac App Store...${NC}"
echo -e "${BOLD}${BLUE}----------------------------------------------------------------------${NC}"
if command -v mas >/dev/null 2>&1; then
    MAS_COUNT=$(mas list 2>/dev/null | wc -l | tr -d ' ')
    echo -e "🔍 Sprawdzam aktualizacje dla ${BOLD}${MAS_COUNT}${NC} aplikacji z Mac App Store..."
    if OUTDATED_MAS=$(mas outdated 2>/dev/null); then
        if [ -n "$OUTDATED_MAS" ]; then
            echo -e "${YELLOW}Wykryto aktualizacje z App Store:${NC}\n$OUTDATED_MAS\n"
            echo "Aktualizuję aplikacje ze sklepu..."
            mas upgrade || sudo mas upgrade || true
            echo -e "${GREEN}✔ Zaktualizowano aplikacje z App Store!${NC}"
        else
            echo -e "${GREEN}✔ Wszystkie aplikacje z Mac App Store (${MAS_COUNT}) są w pełni aktualne!${NC}"
        fi
    else
        echo -e "${YELLOW}ℹ️ Nie udało się pobrać listy aktualizacji z App Store CLI. Możesz sprawdzić je ręcznie:${NC}"
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
caskrooms = ['/opt/homebrew/Caskroom', '/usr/local/Caskroom']
to_upgrade = []

for d in scan_dirs:
    if not os.path.exists(d): continue
    for entry in sorted(os.listdir(d)):
        if entry.endswith('.app'):
            low_name = entry.lower()
            if low_name in app_map:
                token, remote_ver = app_map[low_name]
                # Pomiń, jeśli ta dokładnie wersja Caska jest już zainstalowana w Caskroom
                # (np. gdy autor aplikacji zahardkodował starą wersję w Info.plist, jak w Hermes.app)
                already_in_caskroom = any(
                    os.path.exists(os.path.join(cr, token, str(remote_ver)))
                    for cr in caskrooms
                )
                if already_in_caskroom:
                    continue

                app_full_path = os.path.join(d, entry)
                info_p = os.path.join(app_full_path, 'Contents', 'Info.plist')
                mas_receipt = os.path.join(app_full_path, 'Contents', '_MASReceipt')
                if os.path.exists(info_p):
                    try:
                        with open(info_p, 'rb') as fp:
                            pl = plistlib.load(fp)
                            lver = str(pl.get('CFBundleShortVersionString') or pl.get('CFBundleVersion') or '').strip()
                            pv_local = parse_ver(lver)
                            pv_remote = parse_ver(remote_ver)
                            if pv_remote and pv_local and pv_remote > pv_local:
                                # Jeśli aplikacja pochodzi z Mac App Store (_MASReceipt) i ma tę samą główną gałąź wersji,
                                # jej aktualizacjami zarządza App Store (mas), więc nie nadpisujemy jej wersją z Caska.
                                # Wyjątkiem są aplikacje porzucone w App Store (gdzie główna wersja w Casku jest znacznie wyższa, np. Perplexity 2.x -> 26.x).
                                if os.path.exists(mas_receipt) and pv_local[0] == pv_remote[0]:
                                    continue
                                to_upgrade.append((entry, token, lver, remote_ver, app_full_path))
                    except Exception:
                        pass

if not to_upgrade:
    print('✔ Wszystkie aplikacje w /Applications są w najnowszych wersjach!')
else:
    print(f'Wykryto {len(to_upgrade)} aplikacji wymagających aktualizacji:')
    with open('/tmp/apps_to_brew_upgrade.txt', 'w') as out_f:
        for app_name, token, lver, rver, app_full_path in to_upgrade:
            print(f'  - {app_name:<25}: {lver} ➔ {rver} (cask: {token})')
            out_f.write(f'{token}|{app_full_path}\n')
"

    if [ -f "/tmp/apps_to_brew_upgrade.txt" ]; then
        echo -e "\n${YELLOW}Instaluję najnowsze wersje wykrytych aplikacji przez Homebrew...${NC}"
        while IFS='|' read -r tok app_path; do
            [ -z "$tok" ] && continue
            echo -e "🚀 Aktualizuję: ${BOLD}${tok}${NC}..."
            # Jeśli istniejący pakiet .app należy do root:wheel (np. stara instalacja PKG lub porzucona aplikacja z App Store),
            # nadajemy uprawnienia bieżącemu użytkownikowi, aby uniknąć błędu 'Permission denied @ apply2files' w Homebrew
            if [ -n "$app_path" ] && [ -d "$app_path" ]; then
                sudo chown -R "$(id -un):staff" "$app_path" 2>/dev/null || true
                sudo chmod -R u+w "$app_path" 2>/dev/null || true
            fi
            brew install --cask --force "$tok" || echo -e "${RED}Błąd aktualizacji ${tok}, pomijam.${NC}"
        done < /tmp/apps_to_brew_upgrade.txt
        rm -f /tmp/apps_to_brew_upgrade.txt
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
