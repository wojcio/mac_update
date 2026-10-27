# Antigravity Project Instructions: Universal macOS Updater (`mac_update`)

## 📌 Cel i Przegląd Projektu
Uniwersalny, przenośny automat aktualizacyjny dla systemu macOS (`mac_update_all.sh`). Skrypt rozwiązuje problem rozproszonych źródeł instalacji oprogramowania na platformie Apple (Apple Software Update, Mac App Store, Homebrew Formulae, Homebrew Cask oraz manualnie instalowane programy w `/Applications`).

## 🏗️ Architektura i Decyzje Projektowe
- **Jednoplikiowy Bash + Python 3 (zero dependencies):**
  - Wykorzystuje natywny interpreter `bash` oraz preinstalowanego w macOS `python3` (moduły standardowe: `urllib.request`, `plistlib`, `json`, `re`).
- **Pętla podtrzymania uprawnień `sudo`:**
  - W tle działa subproces odnawiający `sudo -n true` co 50 sekund, zapobiegając wygasaniu uprawnień w trakcie pobierania dużych pakietów.
- **Wielokanałowe aktualizacje (6-fazowy pipeline):**
  1. *Faza 1:* Weryfikacja i opcjonalna instalacja Homebrew oraz `mas` (Mac App Store CLI).
  2. *Faza 2:* Aktualizacje bezpieczeństwa Apple i Safari przez `softwareupdate -ia`.
  3. *Faza 3:* Aktualizacje aplikacji ze sklepu App Store przez `mas update`.
  4. *Faza 4:* Aktualizacja formuł CLI przez `brew update && brew upgrade`.
  5. *Faza 5:* Aktualizacja zarządzanych Casków przez `brew upgrade --cask --greedy`.
  6. *Faza 6 (Auto-Discovery):* Automatyczne mapowanie zainstalowanych aplikacji z `/Applications` i `~/Applications` na bazę Casków Homebrew i bezpieczny upgrade (`brew install --cask --force <token>`) wyłącznie dla wykrytych starszych wersji aplikacji.
- **Sprzątanie:**
  - Czyszczenie pamięci podręcznej instalatorów przez `brew cleanup -s`.

## 📁 Struktura Plików
| Ścieżka | Rola / Przeznaczenie |
|---|---|
| `mac_update_all.sh` | Główny skrypt wykonywalny aktualizatora |
| `mac_update.sh` | Dowiązanie symboliczne do `mac_update_all.sh` |
| `README.md` | Dokumentacja użytkownika i instrukcja uruchomienia |
| `LICENSE` | Licencja MIT |
| `GEMINI.md` | Kontekst projektu, architektura i stan dla Antigravity / agentów AI |

## 🔄 Ostatnie Zmiany i Stan Projektu
- Zainicjalizowano repozytorium zdalne `git@github.com:wojcio/mac_update.git`.
- Dodano główny skrypt `mac_update_all.sh` wraz z symlinkiem `mac_update.sh`.
- Utworzono dokumentację `README.md` oraz plik reguł i kontekstu `GEMINI.md`.
- Wszystkie komponenty przetestowane na macOS Tahoe 26.7.2 (Apple Silicon).
