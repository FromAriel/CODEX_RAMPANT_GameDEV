    ▛▀▜▙▛▄▙▄▜▛▀▜▛▄▙▄▜▛▀▜▛▄▙▄▜▛▀▜▛▄▙▄▜▛▀▜▛▄▙▄▜▛▀▜▛▄▙▄▜▛▄▄
  ▛    ____ ___  ____  ______   ___   __     __   _     _   _  _     _____   ▙
 ▛   / ___/ _ \|  _ \| ___\ \ / /    \ \   / /  / \   | | | | | |   |_   _|    ▜
█    | |  | | | | | | |  _| \ V /      \ \ / /  / ⋏ \  | | | | | |     | |       █
 ▙  | |__| |_| | |_| | |___/ ⋏ \       \ V /  / /_\ \ | |_| | | |__   | |      ▜
  ▜  \____\___/|____/|______/ \__\       \_/  /_/   \_\ \___/ |____|  |_|     ▛
   ▜▙▄▛▜▀▛▙▄▜▙▄▛▜▀▛▙▄▜▙▄▛▜▀▛▙▄▜▙▄▛▜▀▛▙▄▜▙▄▛▜▀▛▙▄▜▙▄▛▜▀


###############################################################################
# 🧰 GODOT BULLETPROOF TOOLING SUITE – README.txt
# Author: Ariel M. Williams
# Purpose: Fully automatic, reproducible, CI-safe setup for Godot, Mono, .NET,
#          and multi-language environments (usable beyond Godot).
###############################################################################

👋 Welcome to your one-stop setup ecosystem for **Godot 4.4.1 (Mono)**, modern .NET SDKs, and a rich polyglot development stack.

These scripts are designed to:

✔️ Fail gracefully without borking the terminal  
✔️ Retry network and installation errors with backoff 
      (eesential for concurrent runs of CODEX, Multiple concurrent D/L of the same file can fail.) 
✔️ Set up robust, CI-friendly, reproducible dev environments  
✔️ Be modular and extensible to fit **any language stack** (not just Godot)

---

📂 FILE OVERVIEW
===============

✔ `setup.sh`
  - Master installer for everything needed to work with Godot, Mono, .NET, and GDToolkit.
  - Also installs essential CLI tools, retries broken installs, and validates your toolchain.

✔ `fix_indent.sh`
  - Fast and safe GDScript auto-formatter for pre-commit.
  - Uses `gdformat` with retry + timeout. If it fails, your commit won’t be blocked permanently.

✔ `AGENTS.md`
  - The Codex Agent Tooling Contract.
  - Describes CI-safe validation, GDScript import passes, lint rules, and style format expectations.

✔ `TOOLS.md`
  - An exhaustive manifest of everything `setup.sh` + the Dockerfile deliver.
  - Lists base packages, languages, dev tools, helper commands, and their install mechanisms.

---

⚙ WHAT DOES IT INSTALL?
========================

From `TOOLS.md`, `setup.sh`, and env logic:

🔧 Core Packages (via APT)
--------------------------
- OS: Ubuntu 24.04 base
- CLI: curl, wget, unzip, html2text, vim-common, lynx, elinks, etc.
- Build: make, cmake, pkg-config, ccache, build-essential
- Networking: dnsutils, netcat, openssh-client
- DevOps: git, git-lfs, rsync
- Browsers (text): `w3m`, `lynx`, `elinks`, `links`

🎮 Godot Engine (Mono)
----------------------
- Installs from official GitHub zip release
- Installs to `/opt/godot-mono/<version>`
- Symlinked to `/usr/local/bin/godot` for easy CLI use

🌐 .NET SDK (via Microsoft apt repo)
------------------------------------
- Installs .NET 8 SDK and runtime
- Uses Microsoft’s official signed keyring
- Integrates with Mono builds inside Godot

🐍 Python / GDToolkit
---------------------
- Installs `gdtoolkit` (for `gdformat`, `gdlint`)
- Sets up `pre-commit` if used in a Git repo
- Ensures the project won’t break CI due to style violations

📦 Godot Runtime Libs
----------------------
- Dynamically installs latest ICU
- Installs audio, Vulkan, GL, and windowing deps: `libgl1`, `libpulse0`, `libxi6`, etc.

---

🔁 HOW DO THE SCRIPTS WORK?
===========================

▶ `setup.sh` – MASTER INSTALLER

1. Updates APT and installs core tooling
2. Dynamically fetches the latest ICU version
3. Downloads and installs `Godot-mono` to a static path
4. Adds `dotnet`, `gdformat`, `gdlint`, `godot` to your PATH
5. Runs a `godot_import_pass` which:
   - Triggers a cache warm-up via `godot --import`
   - Silently ignores known benign warnings
   - Flags errors like broken `main_scene`, or missing `fs` type

6. Verifies essential commands exist
7. Shows a final success log with all key paths

▶ `fix_indent.sh` – SAFE FORMATTER

- Filters input to only run on `.gd` files
- Uses `gdformat --use-spaces=4` with a 20s timeout
- Logs any failure to `/tmp/gdformat.log`
- Fails gracefully with logs, avoiding commit breakage

▶ `AGENTS.md` – TOOLING CONTRACT

- CI build rules and best practices
- Recommends 4-space indentation, class-order for GDScript
- Covers proper patch hygiene, formatting, and retry loop
- Validates both GDScript and C# builds with exit checks

▶ `TOOLS.md` – TOOLCHAIN INVENTORY

- Categorized list of:
  - All installed APT packages
  - Language versions and tooling paths
  - Helper functions (`retry`, `pick_icu`, `godot_import_pass`)
  - Environmental variables (`GODOT_BIN`, `ONLINE_DOCS_URL`)
  - CLI helper utilities installed by language ecosystems

---

🧹 TRIMMING DOWN – LEAN MODE
============================

Want a smaller, faster install? Here’s how to strip it to essentials:

1. **For Godot-only users (no Mono/.NET):**
   - Remove `.NET SDK` section from `setup.sh`
   - Skip `dotnet` build steps and `dotnet format` in validation

2. **For CLI-only environments:**
   - Drop all `w3m`, `lynx`, `elinks`, and HTML-to-text browsers
   - Keep just `curl`, `wget`, `less`, `vim-common`

3. **For single-language use:**
   - Remove unrelated toolchains from `TOOLS.md` for clarity
   - Comment out their installs from Dockerfile if applicable

4. **Remove Pre-commit Hooks (optional):**
   - Delete `pre-commit` section in `setup.sh`
   - Remove `fix_indent.sh` and any `.pre-commit-config.yaml` files

5. **Drop Godot GUI support:**
   - Remove `libpulse`, `libx11`, `mesa-vulkan`, etc. if you only do headless build

---

✅ FINAL THOUGHTS
=================

This suite is designed to be:

- Safe for CI/CD with full validation
- Fully headless-compatible (no GUI needed)
- Portable across teams and languages
- Adaptable to non-Godot use with a few tweaks

Add this README.txt to the root of your repo for contributors.

Happy building!
— ChatGPT & Ariel 💜
