<!--
###############################################################################
# 🧠  Codex Agent Workspace – Tooling Contract & Guide (HIDDEN HEADER)
# Godot 4.4.1 · Headless · CI-safe · .NET 8 SDK + Godot-mono included
###############################################################################
# CODING AGENT BEHAVIOR MODE: VERBOSE · STEPWISE · SAFE · LINT-COMPLIANT · MAXIMUM REASONING TIME 
# PULL REQUEST POLICY: NO BINARIES · NO AUTOCOMPLETE · ONLY CONFIRMED CODE
# VARIABLE PREFIX STYLE: <scriptPrefix>_<name>_<ownerFn> · lowercase_snake_case
# TASK SEQUENCE RULE: FOUNDATION FIRST → UTILITIES → SCENES → FEATURES
# COMMIT MESSAGE STYLE: Conventional Commits (e.g., fix(boids): stabilize swim)
# BUG POLICY: Validate scripts → detect errors → fix → revalidate → repeat.
# Only commit when zero errors. Warnings may pass unless CI blocks them.
# ERROR POLICY: No bypassing errors. No .gdignore, fake returns, or suppression.
# Placeholders and minimal stubs are allowed only for tracked, planned features, 
# Placeholders must not hide script validation failures.
###############################################################################
-->


```text
###############################################################################
# 🧠  Codex Agent Workspace – Tooling Contract & Guide
# Godot 4.4.1 · Headless · CI-safe · .NET 8 SDK + Godot-mono included
###############################################################################
```

> [!IMPORTANT]
>
> * **Indentation:** Always 4 spaces in `.gd`, `.gdshader`, `.cs`. Never use tabs.
> * `gdlint` expects `class_name` **before** `extends`.

> [!IMPORTANT]
>
> Your tools may let you create a PR with a binary file but the user will be unable to merge your changes if you do. All PRs must EXCLUDE binary files of any sort. You may use files that are already present but your pull request cannot alter them or stage them.

> [!IMPORTANT]
>
> You ARE NOT allowed to use .gdignore to avoid error messages! You must correctly fix all errors.
---

## ──── SECTION: GODOT FIRST-TIME SETUP ────

1. **Use the built-in Godot CLI**: `/usr/local/bin/godot` (default in this image).  
   To override, export `GODOT=/full/path/to/godot`.

2. **Import pass** – warm caches & create `global_script_class_cache.cfg`:

   ```bash
   godot --headless --editor --import --quit --path . --verbose .
   ```

3. **Parse all GDScript**:

   ```bash
   godot --headless --check-only --quit --path . --verbose .   # path MUST be repo root
   ```

4. **Build C#/Mono** (auto-skips if no `*.sln`):

   ```bash
   dotnet build --nologo > /tmp/dotnet_build.log
   tail -n 20 /tmp/dotnet_build.log
   ```

   * **Exit 0** ⇒ project is clean.  
   * **Non-zero** ⇒ inspect error lines and fix.

**Repeat steps 2–4 after any edit until all return 0.**

For persistent or challenging errors, use:

```bash
dotnet build --verbosity diagnostic
godot --headless --check-only --nologo --quit --path . --verbose .
```

to enable maximum verbosity and get detailed diagnostic output.

---

## ──── SECTION: PATCH HYGIENE & FORMAT ────

```bash
# Auto-format changed .gd quietly
.codex/fix_indent.sh $(git diff --name-only --cached -- '*.gd') >/dev/null

# Report any lint warnings (non-blocking)
gdlint $(git diff --name-only --cached -- '*.gd') --quiet || true

# C# style check (fail only on real violations)
dotnet format --verify-no-changes --nologo --severity hidden || {
  echo '🛑 C# style violations'; exit 1; }
```
> CODING AGENT RULES:
* **No tabs, no syntax errors, no style violations before commit.**
* Binary files MAY NOT BE ADDED, STAGED, OR COMMITTED under ANY circumstances. -
Changes made for local testing must be untracked or `.git update-index --assume-unchanged` before commit.
* **Review** local TODO.md, CHANGE_LOG.md, STYLE_Guide.md, README.md, and VARIABLE_NAMING.md
If they are not found create them. Update TODO.md and CHANGE_LOG.md before you are done.
---

## ──── SECTION: GODOT VALIDATION LOOP (CI) ────

```bash
# CI validates quietly and only emits errors
godot --headless --editor --import --quit --path . --quiet
godot --headless --check-only --quit --path . --quiet
dotnet build --no-restore --nologo   # errors go to CI log
```

**Optional tests:**

```bash
# Run only if tests exist, suppress regular output
godot --headless -s res://tests/ --quiet || true
dotnet test --logger "console;verbosity=quiet" || true
```

---

## ──── SECTION: QUICK CHECKLIST ────

```text
apply_patch
├─ gdformat  --use-spaces=4 <changed.gd>
├─ gdlint    <changed.gd> (non-blocking)
├─ godot --headless --editor --import  --quit --path . --quiet
├─ godot --headless --check-only       --quit --path . --quiet
└─ dotnet build --no-restore --nologo            # errors => fix
```

---

## ──── SECTION: WHY THIS MATTERS ────

* `--import` is the **only** way to build Godot’s script-class cache.  
* CI **skips** the import when no `main_scene` is set, so fresh repos won’t fail.  
* `--check-only` finds GDScript errors; `dotnet build` ensures C# compiles.  
  Together, these guarantee the project builds headless on any clean machine.

> **TL;DR:** Run the three headless commands with `--quiet`. Exit 0 ⇒ good. Else, fix & rerun.

---

## ──── ADDENDUM: BUILD-PLAN RULE SET ────

1. **Foundation first** – scaffolding (data models, interfaces, utils) is built before high-level features. CI fails fast if missing.  
2. **Design principles** – data-driven, modular, extensible, compartmentalized. Follow each language’s canonical formatter (PEP 8, rustfmt, go fmt, gdformat, etc.).  
3. **Indentation** – spaces-only except where a language **requires** tabs (e.g., `Makefile`). Keep tabs localized to that file type. **_Context:_** The terminal based tools CODEX uses don't play well (or consistantly) with TABs and CODEX doesn't seem to recognize that, best to avoid.  
4. **Header-comment block** – for files that support comments, prepend:

   ```text
   ###############################################################
   # <file path>
   # Key Classes      • Foo – does something important
   # Key Functions    • bar() – handles a critical step
   # Critical Consts  • BAZ – tuning value
   # Editor Exports   • bum: float – Range(0.0 .. 1.0)
   # Dependencies     • foo_bar.gd, utils/foo.gd
   # Last Major Rev   • YY-MM-DD – overhauled bar() for clarity
   ###############################################################
   ```

   Skip for formats with no comments (JSON, minified assets).  
5. **Language-specific tests** – run `cargo test`, `go test`, `bun test`, etc., when present.
6. **Efficent Time Use** You do not need to run .net and Gotdot verify comands if you have not chaged GD or CS files or thier related dependancies. Precommit hooks will check automaticaly anyhow.

---

## ──── ADDENDUM: gdlint CLASS-ORDER WARNINGS ────

`gdlint` 4.x enforces **class-definitions-order**  
(tool → `class_name` → `extends` → signals → enums → consts → exports → vars).

If it becomes noisy:

* Reorder clauses to match the list, or
* Customize via `.gdlintrc`, or  
* Pin `gdtoolkit==4.0.1`.
> [!NOTE] 
> * **Only if no other beter option** Suppress in file
> * `# gdlint:ignore = class-definitions-order`

CI runs `gdlint` **non-blocking**; treat warnings as advice until enforcing them strictly.

---

```text
###############################################################################
# End of Codex Agent Workspace Guide
###############################################################################
```
