# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Run the game: Open project.godot in Godot Engine and press F5
- Build for web: `godot --headless --verbose --export-release "Web" $PWD/build/web/index.html`
- Tests: Run test scenes directly in Godot (open *_test.tscn files and press F5)

## Code Style
- Follow Godot's GDScript style guide
- Indentation: Tabs (not spaces)
- Line length: <100 characters
- File/variable/function names: snake_case
- Class/Node names: PascalCase
- Constants/Enums: UPPER_CASE
- Types: Use static typing for clarity: `var health: int = 0`
- Node references: Always use explicit typing: `@onready var label: Label = $Label`
- Signals: Connect using signal keyword and callable syntax
- Organization: Group code by type (constants, variables, functions)
- Functions: One blank line between functions, two after class definitions
- Comments: Use # for single-line comments, """ for multi-line documentation