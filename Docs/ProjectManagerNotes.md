
# Project Manager Notes
### Project Environment & Tooling

* **Engine & Languages:** Uses Godot 4.4.1 (Mono) on Ubuntu 24.04. Core languages are C# (via .NET 8) and GDScript, with support scripts in Python/Node/etc.  The container includes Git, Git-LFS, build-essential, curl, wget, and other CLI tools.  GDToolkit (`gdformat`, `gdlint`) is installed for GDScript formatting and linting.
* **Toolchain Setup:** A master `setup.sh` script installs Godot-mono, .NET SDK, Python (with GDToolkit), and various runtimes.  Key commands added include `godot` (v4.4.1-mono) and `dotnet` (for C#).  Helper functions like `retry`, `pick_icu`, and `godot_import_pass` handle retries, ICU versioning, and headless import/build steps.
* **Design Philosophy:** Code must be **modular, lightweight, and test-friendly**.  Follow 4‑space indentation (no tabs) and GDScript order (`class_name` before `extends`).  AGENTS.md and CODEXPROMPT.md outline a “tooling contract” enforcing CI-safe builds and style rules.

## Repository Structure

* **Top-level Docs:**

  * `CODEXPROMPT.md` – Instructions for the Codex agent, listing goals, iteration process, and rules.
  * `AGENTS.md` – Environment and CI guide (auto-importing scripts, build steps, formatting, etc.).
  * `DEVLOG.md` / `ROADMAP.md` – Progress log and milestone checklist.  For example, `ROADMAP.md` shows initial targets: player movement, enemy placeholder, scoring/restart.  `DEVLOG.md` already has *“Initial Setup – created Godot project skeleton with player movement.”*.
  * `readme.txt` – Describes the bulletproof tooling (Godot + .NET + GDToolkit) and file roles.
* **Code Directories:**

  * `.codex/` – CI tooling: `setup.sh` (environment installer), `TOOLS.md` (comprehensive tool inventory), `FAQ.md` (philosophy notes), and `.codexignore`.
  * `src/` – Game source. Under `src/scripts/` we have GDScript files: e.g. `main.gd` (root Node2D, currently empty) and `player.gd` (the controllable Player).
  * `tests/` – Intended for test scenes or unit tests (none present yet). CODEXPROMPT advises guarding new code with minimal tests or Godot test scenes.

## Coding & Commit Policies

* **Build Pipeline:** Always run the Godot import & check in headless mode, and compile C# with `dotnet build`. CI requires all these to exit 0. The quick validation loop is:

  1. `godot --headless --editor --import --quit --path .` (warming import cache)
  2. `godot --headless --check-only --quit --path .` (parse scripts)
  3. `dotnet build` (if any C# present).
     If errors occur, fix and rerun until clean.
* **Formatting/Linting:** Before commits, run the provided `fix_indent.sh` and `gdformat`/`gdlint` on changed GDScript. No tabs allowed. Gdlint warnings are advisory (class ordering rule). For C#, use `dotnet format` to enforce code style.
* **Binary Assets Ban:** **Never commit binary or large assets**. An `unstaged_binaries.sh` hook should be run to remove any (enforcing ASSET\_POLICY). Placeholder art is created in code (e.g. `player.gd` spawns a white `ImageTexture` if no sprite node exists).
* **Commit Rules:** Only commit if `codex_build.log` shows zero errors. Commit messages should be scoped (like `feat(core): ...`, `fix(ui): ...`). If irreparable in two attempts, commit with `#BROKEN` tag and leave a TODO in `NEXT_PROMPT.md`.
* **Priority Stack:** The highest priority is a passing build; then get a playable prototype working; then polish/documentation. Keep Git history clean (no broken HEADs) and choose the simplest viable solutions.

## Current Implementation

* **Player:** `player.gd` defines `class_name Player` extending `CharacterBody2D`. In `_physics_process`, it reads `ui_right/left/down/up` strengths into a normalized vector and sets `velocity = input_vec * SPEED`, then calls `move_and_slide()`. This handles 2D movement in all directions.
* **Placeholders:** In `_ready()`, if no `Sprite2D` child exists, it creates a 16×16 white texture and a Sprite2D node. It also adds a `CollisionShape2D` with a `RectangleShape2D`. Thus the player has a simple square avatar and hitbox, with no external art files.
* **Testing Scene:** A basic test scene (e.g. `initial_prototype.tscn`) should exist to verify movement, per task. Headless runs of this scene (via `godot -s`) will catch any immediate errors.
* **Milestones:** According to `ROADMAP.md`, next is an enemy placeholder and scoring/restart. No enemy code exists yet. Likely next steps include creating an `Enemy` (simple AI or kinematic body) and adding a score counter (in a `Main` singleton or scene).

## Game Concept & Goals (“Echoes of Light”)

* **Core Idea:** A minimalist 2D puzzle-platformer where the player (a light-based creature) uses shadows and reflections to solve puzzles. Each level is a fragment of a shattered reality. Levels may be procedurally generated for replayability, but first iterations should use hand-crafted layouts. The tone is serene and mysterious; narrative is conveyed via brief poetic text after each level.
* **Gameplay Mechanics:** Prototype mechanics like movable mirrors and light beams: e.g., pressing a button rotates a mirror to redirect a light ray, or casting a shadow on a sensor reveals a path. These likely use Godot’s `RayCast2D` or `Light2D` nodes and script-driven visibility toggles. Keep initial puzzles extremely simple (one or two elements) to validate the concept.
* **Visual Style:** Start with flat-shaded placeholders: solid-color shapes for platforms, a bright circle for the player, etc. (Later we can add simple shaders for light/shadow effects). No reliance on art assets initially — all imagery will be simple geometry coded in (e.g. changing `Color` or basic textures).
* **Scope & Difficulty:** Given the solo/AI dev context, keep scope tight. The concept is ambitious, but initial goals should focus on one mechanic. For example, first puzzle could be: “move mirror left/right to open a door”. Once that works, iterate. Procedural generation (e.g. cellular automata, WFC) can be an advanced step after core mechanics are solid.

## AI Partner Limitations & Considerations

* **Explicit Coordinates:** The agent has no innate spatial sense. We must explicitly define coordinate conventions. In Godot 2D, +X is right, +Y is down (origin at top-left). So “move up” means `velocity.y = -SPEED`. We already use `Input.get_action_strength("ui_up")` which yields positive for “Up arrow” input, so note that in code it’s subtracted into a normalized Vector2. Always spell out direction logic in code comments.
* **Input Mapping:** Godot’s default `ui_*` actions are used (Arrow keys). Ensure these InputMap settings exist or are defined. CODEX cannot guess missing inputs, so any custom action (e.g. “jump” or “toggle”) must be created via code or project settings.
* **No Vision:** CODEX cannot “see” the game. We should use logging to validate gameplay. For example, after coding a puzzle, we might run the game headless and dump player position, enemy state, or trigger flags to the log. The prompt even suggests writing a debug script that logs object distances at 1fps. Utilize print statements or GDNative logging to trace logic.
* **Testing:** Write small automated tests when possible. E.g., a test scene could position the player and mirror in known spots and assert that toggling the mirror changes platform visibility. After each coding sprint, run `godot --headless --test` (if using Godot’s built-in testing) or at least `godot --headless --check-only` to catch errors.
* **Limit Complexity:** The agent won’t inherently recognize classic game design patterns (like Lemmings or Tetris) without being told. Keep puzzles self-contained and incremental. If we say “jump on platform”, define the jump impulse explicitly (e.g. `velocity.y = -JUMP_SPEED`) and ensure gravity exists in the scene.

## Next Steps & Task Ideas

* **Finalize Iteration 1:** Ensure core movement is solid. Implement jump/gravity if not done. Create a “ground” StaticBody2D with collision to test falling/jumping. Tweak speed/gravity constants by logging jump height or fall speed.
* **Enemy Placeholder:** Create a simple enemy scene (e.g. an `Enemy.gd` extending `Area2D` or `CharacterBody2D`) with a collision shape and basic behavior (patrol or just stationary). On collision with Player, trigger a restart or health decrement. Use a placeholder sprite (like another color square) created via code.
* **Scoring & Restart:** Add a global `score` variable (in `Main.gd` or a singleton). When an enemy is defeated or level completed, increment score. Display it with a `Label`. Detect player death (e.g. collision with enemy or out-of-bounds) and reload the scene (`get_tree().reload_current_scene()` in Godot 4).
* **Prototype Shadow Mechanic:** Start a new test scene where the player can move an object (mirror) and there’s a light or ray. Perhaps have a `RayCast2D` attached to the player/mirror and a light source. Write a script so that when the ray hits a specific Area2D, it toggles a door (another StaticBody2D) visibility or collision. Verify this works headlessly by checking the door’s `disabled` state.
* **Narrative UI:** Implement a simple UI element (`RichTextLabel`) that shows a line of story text. Trigger it after completing a puzzle (e.g. disabling player controls and showing text). Keep it non-interactive (just “Press Enter to continue”). We can later test this by simulating a scene end.
* **Adhere to Agent Workflow:** Each iteration, remember to pick **≥2 tasks**: typically “Advance Roadmap” (e.g. enemy or scoring) plus “Prototype & Test” (e.g. test the shadow mechanic). After coding, update `DEVLOG.md` with what was done and any fun-factor assessment. Commit frequently with clean messages and zero errors.
* **Documentation:** Keep notes in `DEVLOG.md` or a new `BRAINSTORM.md` about any design changes or ideas. For example, log any tricky coordinates math or puzzle ideas. Review and adjust `CODEXPROMPT.md` if you find the workflow instructions need tweaking (the prompt encourages this).

All these observations and plans should be preserved in the project documentation (logs, brainstorm files) so the information isn’t lost. Continuously cross-reference **AGENTS.md** and **CODEXPROMPT.md** as the authoritative guide to coding rules. This ensures the AI agent stays on track with the expected process while we flesh out the game concept.
