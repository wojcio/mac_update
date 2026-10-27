# 🚀 Przewodnik: Nowoczesny Zsh na macOS

Kompletny podręcznik korzystania ze skonfigurowanego środowiska powłoki Zsh. Wszystkie narzędzia są zoptymalizowane pod kątem szybkości (Rust/C++), czytelności i wygody codziennej pracy w terminalu.

---

## ⚡ Szybka ściągawka skrótów (Cheat Sheet)

| Klawisze | Co robi? | Narzędzie |
|---|---|---|
| `Ctrl + R` | **Interaktywne przeszukiwanie historii komend** z podglądem w locie | `fzf` |
| `Ctrl + T` | **Wyszukiwarka plików** z podglądem zawartości (`bat`) i wstawianiem do linii | `fzf` + `bat` |
| `Alt + C` | **Fuzzy jump do podkatalogu** (wybierz folder i natychmiast tam przejdź) | `fzf` |
| `→` (Strzałka w prawo) | **Zatwierdzenie szarej podpowiedzi** z historii | `zsh-autosuggestions` |
| `↑` / `↓` (z prefiksem) | **Filtrowanie historii** wg tego, co już wpisałeś (np. `git` + `↑`) | Zsh ZLE |
| `Tab` | **Menu autouzupełniania** z podziałem i kolorami typów plików | Zsh Completion |
| `z <nazwa>` | **Skok do najczęstszego katalogu** bez wpisywania pełnej ścieżki | `zoxide` |
| `zi` | **Interaktywny wybór katalogu** z bazy najczęściej odwiedzanych | `zoxide` + `fzf` |
| `md <plik.md>` | **Konsolowy render Markdown** w czytelnym formacie z przewijaniem | `glow` |

---

## 1. 🔍 Błyskawiczna historia: `Ctrl + R` (`fzf`)

Zapomnij o mozolnym wciskaniu strzałki w górę lub standardowym `Ctrl + R`.

* Wciśnij **`Ctrl + R`**.
* Wpisz dowolne słowa kluczowe (nawet z błędami lub nie po kolei, np. `dock run test`).
* Strzałkami `↑` / `↓` wybierz komendę i naciśnij `Enter` (aby wykonać) lub `Tab` (aby wstawić do edycji).

---

## 2. 📁 Inteligentna nawigacja: `zoxide` zamiast `cd`

`zoxide` uczy się folderów, które odwiedzasz. Im częściej do nich zaglądasz, tym mniej musisz wpisywać.

* Zamiast:
  ```zsh
  cd /Users/wojcio/Documents/Projekty/klient/backend
  ```
* Wpisz po prostu:
  ```zsh
  z backend
  # lub nawet:
  z back
  ```
* **Interaktywny wybór (`zi`):**
  Wpisz `zi`, a zobaczysz listę wszystkich znanych katalogów z punktacją wagową, którą możesz filtrować przez `fzf`.
* Zwykłe `cd` nadal działa dokładnie tak samo, ale `z` oszczędza czas.

---

## 3. 📄 Kolorowe listowanie: `eza` (Nowy `ls`)

Zamiast standardowego, czarno-białego `ls`, masz do dyspozycji:

* **`ls`** – przejrzysta lista z ikonami, posortowana z katalogami na początku.
* **`ll`** – pełny widok (`-lah`) z uprawnieniami, rozmiarem, datą oraz **statusem repozytorium Git** (czy pliki są modyfikowane/nowe).
* **`l`** – kompaktowy widok szczegółowy (`-lh`).
* **`tree`** – kolorowe drzewo katalogów i plików (`eza --tree`).

---

## 4. 🔎 Przeglądanie i podgląd plików: `bat` (Nowy `cat`)

Polecenie `cat` zostało zmapowane na `bat`:
* Automatyczne kolorowanie składni dla plików źródłowych, konfiguracji (`.json`, `.yaml`, `.toml`, `.zshrc`), skryptów i markdown.
* Wskazuje numery linii i zmiany w Git (zielone `+` przy nowych liniach, niebieskie `~` przy edytowanych).
* Wyszukiwanie plików przez **`Ctrl + T`** wyświetla podgląd pliku w czasie rzeczywistym dzięki integracji `fzf` + `bat`.

---

## 5. 📖 Konsolowy render Markdown: `glow` (Polecenie `md`)

Podczas gdy `bat` wyświetla surowy kod Markdown z kolorowaniem składni, **`glow`** renderuje go w sformatowany dokument graficzny w terminalu (duże nagłówki, estetyczne tabele, listy zadań, ramki):

* **Szybki podgląd z przewijaniem:**
  ```zsh
  md README.md
  # lub
  md jak_uzywac_nowego_zsh.md
  ```
  *(Poruszasz się strzałkami lub `j`/`k`, wyjście klawiszem `q`).*

* **Interaktywna przeglądarka plików TUI:**
  Wpisz samo:
  ```zsh
  glow
  ```
  aby otworzyć interaktywne menu przeglądania wszystkich plików `.md` w bieżącym katalogu lub ostatnich dokumentów.

* **Renderowanie z Internetu / GitHub:**
  ```zsh
  glow https://github.com/charmbracelet/glow
  ```

---

## 6. 🎨 Kolorowanie składni w locie (`zsh-syntax-highlighting`)

Podczas wpisywania komend terminal na żywo weryfikuje ich poprawność:
* **Zielony:** polecenie lub alias istnieje i jest gotowe do uruchomienia.
* **Czerwony:** błąd składni, literówka lub brak takiego programu w `$PATH`.
* **Podkreślenie:** rozpoznana istniejąca ścieżka do pliku lub katalogu.
* **Żółty / cyjan:** poprawne flagi, zmienne i cudzysłowy.

---

## 7. 💡 Podpowiedzi w tle (`zsh-autosuggestions`)

Shell analizuje Twoją historię i podpowiada dokończenie komendy szarym tekstem:
* Aby zaakceptować podpowiedź: wciśnij **strzałkę w prawo `→`** lub klawisz **`End`**.
* Aby zaakceptować tylko jedno słowo: wciśnij **`Option + →`** (lub `Alt + →`).

---

## 8. 🎯 Menu Tab i Kolory Typów Plików

Po wpisaniu początku nazwy i wciśnięciu `Tab`:
* Pojawia się interaktywne menu wyboru (poruszasz się strzałkami `←` `→` `↑` `↓`).
* Pliki są wyróżnione kolorami:
  * 🟦 **Katalogi:** niebieski pogrubiony
  * 🟩 **Pliki wykonywalne / binarne:** zielony pogrubiony
  * 🟨 **Dokumenty (`.pdf`, `.json`, `.yaml`):** żółty
  * 🟥 **Archiwa (`.zip`, `.tar`, `.gz`, `.7z`):** czerwony pogrubiony
  * 🟪 **Grafika i wideo (`.png`, `.jpg`, `.mp4`):** magenta / fiolet
  * 🔷 **Symlinki i pliki Markdown (`.md`):** cyjan

---

## 9. 🧠 Inteligentna historia i zachowanie Zsh

* **Filtrowanie strzałkami `↑` / `↓`:**
  Wpisz np. `brew ` i wciśnij `↑` – terminal pokaże wyłącznie wcześniejsze komendy `brew`, pomijając wszystko inne.
* **Współdzielenie historii (`SHARE_HISTORY`):**
  Wszystkie otwarte karty i okna terminala natychmiast widzą komendy wykonane w innych kartach.
* **Czystość i prywatność:**
  * Jeśli zaczniesz polecenie od spacji (np. ` export API_KEY=xyz`), komenda **nie zostanie zapisana w historii**.
  * Duplikaty komend są automatycznie usuwane (historia pomieści do 50 000 unikalnych poleceń).
* **`AUTO_CD`:**
  Aby wejść do katalogu, nie musisz pisać `cd`. Wystarczy wpisać samą nazwę, np.:
  ```zsh
  ..          # przejdź katalog wyżej
  Downloads   # wejdź do folderu Downloads
  ```

---

## 10. ⭐ Nowoczesny prompt: `Starship`

Pasek zachęty dostosowuje się kontekstowo do tego, nad czym pracujesz:
* Pokazuje aktualną gałąź Git (`main`, `feature/x`) oraz ikonę stanu (niezacommitowane zmiany).
* Gdy wejdziesz do projektu Pythona, Node'a, Rusta lub Dockera – wyświetla aktualną wersję środowiska.
* Czas trwania komendy (jeśli operacja trwała dłużej niż 2s).
* Czerwony symbol w przypadku błędu (np. kod wyjścia różny od zera).
