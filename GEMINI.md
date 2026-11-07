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
- **Naprawa migracji porzuconych aplikacji z Mac App Store (np. `Perplexity.app`) i obsługi `mas 7.0.0` w `mac_update_all.sh` (07.11.2026):**
  - Zdiagnozowano przyczynę blokady aktualizacji `Perplexity.app` (`2.260428.0` z Mac App Store ➔ `26.43.0` z Homebrew Cask):
    1. Pozostałość po przerwanym upgrade'zie w `/opt/homebrew/Caskroom/perplexity/26.42.0/Perplexity.app` (katalog zamiast symlinku) powodowała błąd Homebrew `It seems there is already an App at '/opt/homebrew/Caskroom/...'`.
    2. Zabezpieczenie macOS TCC (`App Management` / `Zarządzanie aplikacjami`) blokowało modyfikację w miejscu (`sudo chown -R`) na pakiecie `.app` należącym do `root:wheel` z `_MASReceipt`, przez co Homebrew wywalał się na nieuprzywilejowanym `FileUtils.rm_r`.
  - Dodano funkcję [`prepare_app_for_cask_replace`](file:///Users/wojcio/mac_update/mac_update_all.sh#L207-L264), która:
    - Czyści osierocone katalogi `.app` (niebędące symlinkami) w `Caskroom` przed `brew upgrade --cask` oraz przed `brew install --cask --force`.
    - Dla porzuconych aplikacji z App Store (`_MASReceipt`, właściciel `root`) wywołuje oficjalne `sudo mas uninstall --bundle <bundle_id>` oraz `sudo rm -rf`, a w razie zablokowania przez macOS TCC wyświetla czytelny komunikat o włączeniu terminala i aplikacji pochodnych w `Ustawienia systemowe → Prywatność i ochrona → Zarządzanie aplikacjami`.
  - W Kroku 3/6 zmieniono kolejność wywołania na `sudo mas upgrade || mas upgrade`, ponieważ `mas 7.0.0` wymaga uprawnień `root` do aktualizacji pakietów z App Store (np. `Prime Video`).
  - Zaktualizowano `README.md` o instrukcję nadawania uprawnień macOS TCC (`Zarządzanie aplikacjami` / `App Management`) dla terminali (`Terminal`, `iTerm2`, `Ghostty`, `Warp`) oraz środowisk pochodnych (`Antigravity`, `VS Code`, `Cursor`, `Zed`).
- **Wybór trybu aktualizacji systemowej macOS, poprawka `mas CLI` i uprawnień Auto-Discovery w `mac_update_all.sh` (31.10.2026):**
  - Dodano interaktywne pytanie w Kroku 2/6 (`softwareupdate`), pozwalające wybrać między instalacją wyłącznie poprawek dla bieżącej zainstalowanej wersji macOS (domyślnie, np. gałąź `26.x`, Safari, XProtect) a podniesieniem głównej wersji systemu (np. do `macOS 27+`).
  - Dodano parser etykiet `softwareupdate -l` w Pythonie 3 odfiltrowujący duże wydania macOS, gdy użytkownik wybierze tylko łatki dla obecnej wersji, i instalujący wybrane poprawki przez `softwareupdate -i <labels>`.
  - Usunięto wycofane w nowym `mas CLI` polecenie `mas account` w Kroku 3/6 na rzecz bezpośredniego sprawdzania `mas list` i `mas outdated` oraz aktualizacji przez `mas upgrade`.
  - W Kroku 6/6 (Auto-Discovery) naprawiono błąd `Permission denied @ apply2files` przy aktualizowaniu aplikacji należących do `root:wheel` (np. `Perplexity.app` wycofana z Mac App Store i zastępowana nową wersją z Homebrew Cask) poprzez automatyczne nadanie uprawnień bieżącemu użytkownikowi (`sudo chown -R`), pomijanie aktywnych aplikacji z App Store (`_MASReceipt` w tej samej gałęzi wersji) oraz pomijanie Casków już zainstalowanych w tej samej wersji w `Caskroom`.
- **Wzbogacenie repozytorium o moduł terminala Zsh (28.10.2026):**
  - Dodano `zsh_tools.sh` (instalator 8 narzędzi CLI: `eza`, `fzf`, `zoxide`, `bat`, `glow`, `starship`, `zsh-syntax-highlighting`, `zsh-autosuggestions`).
  - Dodano `jak_uzywac_nowego_zsh.md` (szczegółowy przewodnik, tabele skrótów, instrukcja konfiguracji).
  - Zaktualizowano `README.md` o sekcję dedykowaną Zsh z jednolinijkowymi komendami uruchomienia (`curl | bash`).
  - Zaktualizowano plik kontekstu `GEMINI.md`.
