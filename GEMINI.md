# Antigravity Project Instructions: Universal macOS Toolkit & Maintenance (`mac_update`)

## 📌 Cel i Przegląd Projektu
Zbiór uniwersalnych, przenośnych skryptów automatyzacji i konfiguracji środowiska dla systemu macOS. Repozytorium łączy dwa filary:
1. **Automatyzację aktualizacji systemu i oprogramowania (`mac_update_all.sh`):** rozstrzyga problem rozproszonych kanałów aktualizacji na macOS (Apple Software Update, Mac App Store, Homebrew Formulae, Homebrew Cask, aplikacje manualne).
2. **Nowoczesną konfigurację powłoki Zsh (`zsh_tools.sh`):** automatyzuje instalację i idempotentną konfigurację nowoczesnego środowiska CLI (eza, fzf, zoxide, bat, glow, starship, zsh-syntax-highlighting, zsh-autosuggestions) na dowolnym Macu.

## 🏗️ Architektura i Decyzje Projektowe
- **`mac_update_all.sh` (Bash + Python 3, zero dependencies):**
  - Subproces odnawiający `sudo -n true` co 50 sekund w tle.
  - 6-fazowy pipeline aktualizacyjny (Apple `softwareupdate` z interaktywnym wyborem: tylko poprawki dla bieżącej gałęzi macOS vs pełny upgrade do nowej głównej wersji systemu, `mas CLI`, `brew update/upgrade`, `brew upgrade --cask --greedy`, Auto-Discovery z `Info.plist` i API Homebrew).
  - Bezpieczne sprzątanie instalatorów (`brew cleanup -s`).
- **`zsh_tools.sh` (Bash, idempotentny instalator CLI):**
  - Wykrywa platformę Apple Silicon (`/opt/homebrew`) oraz Intel (`/usr/local`).
  - Auto-weryfikacja i instalacja Homebrew.
  - Wstrzykiwanie konfiguracji Zsh w oznaczonych markerach (`# >>> modern-zsh-tools >>>` / `# <<< modern-zsh-tools <<<`) zapobiegające powielaniu wpisów.
  - Automatyczna kopia zapasowa `~/.zshrc` ze znacznikiem czasu przed modyfikacją.
  - Weryfikacja składni powłoki przez `zsh -n ~/.zshrc`.

## 📁 Struktura Plików
| Ścieżka | Rola / Przeznaczenie |
|---|---|
| `mac_update_all.sh` | Główny skrypt aktualizatora systemu i aplikacji |
| `mac_update.sh` | Dowiązanie symboliczne do `mac_update_all.sh` |
| `zsh_tools.sh` | Uniwersalny instalator i konfigurator nowoczesnego środowiska Zsh |
| `jak_uzywac_nowego_zsh.md` | Kompletny podręcznik użytkownika i ściągawka skrótów klawiszowych |
| `README.md` | Dokumentacja projektu dla użytkowników końcowych |
| `LICENSE` | Licencja MIT |
| `GEMINI.md` | Kontekst projektu, architektura i stan dla Antigravity / agentów AI |

## 🔄 Ostatnie Zmiany i Stan Projektu
- **Wybór trybu aktualizacji systemowej macOS oraz poprawka `mas CLI` w `mac_update_all.sh` (31.10.2026):**
  - Dodano interaktywne pytanie w Kroku 2/6 (`softwareupdate`), pozwalające wybrać między instalacją wyłącznie poprawek dla bieżącej zainstalowanej wersji macOS (domyślnie, np. gałąź `26.x`, Safari, XProtect) a podniesieniem głównej wersji systemu (np. do `macOS 27+`).
  - Dodano parser etykiet `softwareupdate -l` w Pythonie 3 odfiltrowujący duże wydania macOS, gdy użytkownik wybierze tylko łatki dla obecnej wersji, i instalujący wybrane poprawki przez `softwareupdate -i <labels>`.
  - Usunięto wycofane w nowym `mas CLI` polecenie `mas account` w Kroku 3/6 na rzecz bezpośredniego sprawdzania `mas list` i `mas outdated` oraz aktualizacji przez `mas upgrade`.
- **Wzbogacenie repozytorium o moduł terminala Zsh (28.10.2026):**
  - Dodano `zsh_tools.sh` (instalator 8 narzędzi CLI: `eza`, `fzf`, `zoxide`, `bat`, `glow`, `starship`, `zsh-syntax-highlighting`, `zsh-autosuggestions`).
  - Dodano `jak_uzywac_nowego_zsh.md` (szczegółowy przewodnik, tabele skrótów, instrukcja konfiguracji).
  - Zaktualizowano `README.md` o sekcję dedykowaną Zsh z jednolinijkowymi komendami uruchomienia (`curl | bash`).
  - Zaktualizowano plik kontekstu `GEMINI.md`.
