# 🍏 macOS Toolkit & Maintenance (`mac_update`)

Zestaw uniwersalnych, zautomatyzowanych narzędzi dla systemu macOS (obsługujących architekturę **Apple Silicon M1/M2/M3/M4** oraz **Intel**).

Repozytorium zawiera dwa kluczowe skrypty:
1. **[`mac_update_all.sh`](#1-uniwersalny-updater-macos-mac_update_allsh)** – wszechstronny kombajn aktualizacyjny dla systemu i wszystkich aplikacji.
2. **[`zsh_tools.sh`](#2-instalator-nowoczesnego-środowiska-zsh-zsh_toolssh)** – automatyczny konfigurator nowoczesnej powłoki Zsh (szybkie narzędzia CLI w Rust/Go, autouzupełnianie, kolory i podpowiedzi).

---

## 1. 🔄 Uniwersalny Updater macOS (`mac_update_all.sh`)

Kompleksowa aktualizacja całego ekosystemu oprogramowania na Macu: od łatek bezpieczeństwa Apple po aplikacje firm trzecich, bez instalowania niechcianych pakietów.

### ⚡ Główne Możliwości
* **Utrzymywanie uprawnień `sudo` w tle:** pyta o hasło tylko raz na początku i podtrzymuje sesję do końca.
* **Aktualizacje systemowe Apple (z wyborem trybu):** pyta użytkownika, czy chce zainstalować wyłącznie poprawki i łatki bezpieczeństwa dla bieżącej wersji macOS (np. gałęzi `26.x`, Safari, XProtect), czy również podnieść główną wersję systemu do kolejnego wydania (`softwareupdate`).
* **Mac App Store:** automatycznie aktualizuje aplikacje ze sklepu przez narzędzie `mas CLI` (w pełni kompatybilne z `mas 7.0+` wymagającym `sudo`).
* **Homebrew:** aktualizuje formuły CLI (`brew update && brew upgrade`) oraz zarządzane programy GUI (`brew upgrade --cask --greedy`), automatycznie naprawiając przerwane instalacje i osierocone katalogi w `Caskroom`.
* **🧠 Inteligentny Auto-Discovery i migracja porzuconych aplikacji z App Store:**
  * Skanuje `/Applications` i `~/Applications`, odczytuje wersje z `Info.plist` i porównuje z API Homebrew.
  * Automatycznie wykrywa aplikacje wycofane z Mac App Store (posiadające stary `_MASReceipt` oraz właściciela `root:wheel`, np. `Perplexity.app`), odinstalowuje przestarzałą wersję systemową przez `sudo mas uninstall` i zastępuje ją najnowszym wydaniem z Homebrew Cask.
  * Aktualizuje **wyłącznie** programy już obecne na dysku — nie narzuca żadnego niechcianego oprogramowania.
* **Sprzątanie:** usuwa przestarzałe instalatory i zwalnia miejsce na dysku (`brew cleanup -s`).

### 🔐 Wymagane uprawnienia macOS (Terminal i pochodne aplikacje)

> [!IMPORTANT]
> Od systemu macOS Ventura (13+) mechanizm bezpieczeństwa **TCC (Transparency, Consent, and Control)** domyślnie blokuje modyfikację oraz usuwanie pakietów w `/Applications` (szczególnie aplikacji zainstalowanych wcześniej z Mac App Store lub należących do `root:wheel`), nawet podczas używania `sudo`.
>
> Aby skrypt mógł bezbłędnie aktualizować wszystkie aplikacje GUI (Cask oraz migracje z App Store), nadaj uprawnienia swojemu terminalowi oraz edytorom/agentom, z których uruchamiasz skrypt:
>
> 1. Otwórz **Ustawienia systemowe** (`System Settings`) ➔ **Prywatność i ochrona** (`Privacy & Security`).
> 2. Wejdź w sekcję **Zarządzanie aplikacjami** (`App Management`) — *opcjonalnie również w **Pełny dostęp do dysku** (`Full Disk Access`)*.
> 3. Włącz przełącznik (lub dodaj przyciskiem `+`) dla używanych programów terminalowych i środowisk pochodnych:
>    - **Terminale:** `Terminal.app`, `iTerm2`, `Ghostty`, `Warp`, `Alacritty`, `Kitty`
>    - **IDE / Agenci AI (jeśli uruchamiasz skrypt z ich wbudowanego terminala):** `Antigravity`, `Visual Studio Code`, `Cursor`, `Zed`, `JetBrains IDEs`
> 4. Po włączeniu uprawnienia zrestartuj dany terminal/aplikację.

### 🚀 Szybki Start:
```bash
./mac_update_all.sh
```
*Lub jednolinijkowo:*
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wojcio/mac_update/main/mac_update_all.sh)
```

---

## 2. 🚀 Instalator Nowoczesnego Środowiska Zsh (`zsh_tools.sh`)

Błyskawiczny instalator i konfigurator nowoczesnego terminala na dowolnym Macu. Zamienia domyślny, surowy `zsh` w ultra-wydajne środowisko z kolorowaniem składni, inteligentną historią i szybkimi narzędziami wiersza poleceń.

### 📦 Zainstalowane i skonfigurowane narzędzia:
* **`eza`** – nowoczesny zamiennik `ls` (kolorowanie wg typu plików, ikony, status Git, drzewo katalogów).
* **`fzf`** – interaktywny fuzzy finder pod `Ctrl+R` (wyszukiwanie w historii w locie) i `Ctrl+T` (wyszukiwanie plików).
* **`zoxide`** – błyskawiczna nawigacja katalogami (`z <folder>` zamiast długich ścieżek `cd`).
* **`bat`** – nowoczesny `cat` z kolorowaniem składni kodu i numeracją linii (używany też jako podgląd w `fzf`).
* **`glow`** – konsolowy render plików Markdown w estetycznej formie (alias `md <plik.md>`).
* **`starship`** – szybki, kontekstowy prompt (pokazuje gałąź Git, status zmian, wersję Node/Python).
* **`zsh-syntax-highlighting`** – kolorowanie komend w locie (zielony = poprawna, czerwony = błąd).
* **`zsh-autosuggestions`** – podpowiedzi z historii w tle w stylu Fish shella (akceptacja `→`).
* **Optymalizacje Zsh:** współdzielenie historii między kartami (`SHARE_HISTORY`), inteligentne strzałki `↑`/`↓` filtrujące po wpisanym prefiksie oraz pomijanie komend ze spacją na początku.

### 🚀 Szybki Start:
```bash
./zsh_tools.sh
```
*Lub jednolinijkowo na nowym Macu:*
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wojcio/mac_update/main/zsh_tools.sh)
```

> [!TIP]
> Pełny podręcznik użytkownika wraz ze ściągawką wszystkich skrótów klawiszowych znajdziesz w pliku **[`jak_uzywac_nowego_zsh.md`](jak_uzywac_nowego_zsh.md)**.

---

## 💻 Wymagania i Kompatybilność

- **System:** macOS 13 (Ventura), macOS 14 (Sonoma), macOS 15 (Sequoia), macOS 26 (Tahoe) lub nowszy.
- **Architektura:** Apple Silicon (`arm64`) oraz Intel (`x86_64`).
- **Narzędzia:** Jeśli na danym Macu brakuje Homebrew, skrypty po potwierdzeniu zainstalują je automatycznie.

---

## 📄 Licencja

Projekt udostępniony na licencji MIT (patrz plik [LICENSE](LICENSE)).
