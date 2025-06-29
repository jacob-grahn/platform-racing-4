## Testing
After making a change, validate that the game still works.
Run specific tests as a comma separated list. See test_runner.gd for the tests that exist. Prefer running specific tests if possible, as it is much faster. Example: `/Applications/Godot.app/Contents/MacOS/Godot --run-tests game,editor`
Run all the tests with `all`: `/Applications/Godot.app/Contents/MacOS/Godot --run-tests all`

## Code Style
- Indentation: Tabs (not spaces)
- Line length: <100 characters
- File/variable/function names: snake_case
- Class/Node names: PascalCase
- Constants/Enums: UPPER_CASE
- Types: Use static typing for clarity: `var health: int = 0`
- Node references: Always use explicit typing: `@onready var label: Label = $Label`
- Signals: Connect using signal keyword and callable syntax
- Organization: Group code by type (constants, variables, functions)
- Functions: Surround functions and class definitions with two blank lines, use one blank line inside functions to separate logical sections.
- Comments: Use # for single-line comments, """ for multi-line documentation

## Misc
After adding a new autoload, the linter won't pick it up until the editor has been restarted. Ask me for a restart if needed.
