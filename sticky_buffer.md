# Sticky Buffer

## Opening normal buffers

- SB00: `:e a.txt` in main window
  - Expect: opened and focused in main window
- SB01: `:sp b.txt` in main window
  - Expect: opened and focused a new window on top of main window
- SB02: `:e c.txt` in splited window
  - Expect: opened and focused in current window

## Opening normal buffers in side bar

- Prerequisite:
  - `nvim a.txt b.txt -c 'sp c.txt | e d.txt | NERDTree'`
- SB10: `:e a.txt` in sidebar
  - Expect: focused on `a.txt` in main window
  - Post: `:wincmd h`
- SB11: `:e b.txt` in sidebar
  - Expect: focused on `b.txt` in main window
  - Post: `:wincmd h`
- SB12: `:e d.txt` in sidebar
  - Expect: focused on `d.txt` in splited window
  - Post: `:wincmd h`
- SB13: `:e c.txt` in sidebar
  - Expect: focused on `c.txt` in main window
  - Post: `:wincmd h`
- SB14: `:e e.txt` in sidebar
  - Expect: focused on `e.txt` in main window
  - Post: `:wincmd h`

## Opening document buffers

- Prerequisite:
  - `nvim a.txt -c sp 'NERDTree'`
- SB20: `:h sp` in main window
  - Expect: focused on `:sp` in new document window
  - Post: `:wincmd p`
- SB21: `:Man echo` in main window
  - Expect: focused on `BUILTIN(1)` in exist document window
  - Post: `:wincmd h`
- SB22: `:h wincmd` in sidebar
  - Expect: focused on `:wincmd` in exist document window
  - Post: `:wincmd h`
- SB23: `:Man source` in sidebar
  - Expect: focused on `BUILTIN(1)` in exist document window
