# 🍏 Universal macOS Updater (`mac_update`)

Uniwersalny, zautomatyzowany skrypt aktualizacyjny dla systemu macOS (Apple Silicon M1/M2/M3/M4 oraz Intel). 

Obsługuje kompleksowo cały ekosystem oprogramowania na Macu: od łatek bezpieczeństwa Apple po aplikacje firm trzecich, bez instalowania niechcianych pakietów.

---

## ⚡ Główne Możliwości

1. **Utrzymywanie uprawnień `sudo` w tle:**
   - Pyta o hasło administratora tylko raz na początku i podtrzymuje sesję do zakończenia pracy.
2. **Aktualizacje systemowe Apple:**
   - Sprawdza i instaluje poprawki systemowe macOS, Safari oraz konfiguracje bezpieczeństwa XProtect (`softwareupdate`).
3. **Mac App Store:**
   - Wykrywa aplikacje ze sklepu Mac App Store i automatycznie uaktualnia je za pośrednictwem narzędzia `mas CLI`.
4. **Menedżer pakietów Homebrew:**
   - Aktualizuje bazę repozytoriów (`brew update`) oraz wszystkie narzędzia wiersza poleceń (`brew upgrade`).
   - Aktualizuje zarządzane aplikacje GUI (`brew upgrade --cask --greedy`).
5. **🧠 Inteligentny Auto-Discovery (Aplikacje spoza Caska / zainstalowane ręcznie):**
   - Skanuje katalogi `/Applications` oraz `~/Applications`.
   - Odczytuje wersje lokalne z plików `Info.plist` (`CFBundleShortVersionString`).
   - Łączy się z publicznym rejestrem `formulae.brew.sh/api/cask.json` i porównuje wersje (wyklucza wersje nightly / beta / dev).
   - **Bezpieczeństwo:** Aktualizuje wyłącznie te programy, które są już obecne w systemie — niczego nie narzuca i nie instaluje aplikacji, których użytkownik nie ma!
6. **Sprzątanie (`brew cleanup`):**
   - Usuwa stare wersje pobranych instalatorów, czyszcząc przestrzeń dyskową.

---

## 🚀 Szybki Start

### Klonowanie repozytorium:
```bash
git clone git@github.com:wojcio/mac_update.git
cd mac_update
chmod +x mac_update_all.sh
./mac_update_all.sh
```

### Lub bezpośrednie uruchomienie jednolinijkowe:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wojcio/mac_update/main/mac_update_all.sh)
```

---

## 💻 Wymagania i Kompatybilność

- **System:** macOS 13 (Ventura), macOS 14 (Sonoma), macOS 15 (Sequoia), macOS 26 (Tahoe) lub nowszy.
- **Architektura:** Apple Silicon (`arm64`) oraz Intel (`x86_64`).
- **Narzędzia:** Jeśli na danym Macu nie ma zainstalowanego menedżera `Homebrew` lub narzędzia `mas`, skrypt zapyta o zgodę i automatycznie je zainstaluje.

---

## 📄 Licencja

Projekt udostępniony na licencji MIT (patrz plik [LICENSE](LICENSE)).
