## Testing
After making a change, validate that the game still works.
Run all the tests with this command: `/Applications/Godot.app/Contents/MacOS/Godot --run-tests all`
You can also run specific tests as a comma separated list. See test_runner.gd for the tests that exist. Prefer running specific tests if possible, as it is much faster. Example: `/Applications/Godot.app/Contents/MacOS/Godot --run-tests game,editor`

Ignore these errors:
 - ObjectDB instances leaked at exit 

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
