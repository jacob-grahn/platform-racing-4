## Testing
After making a change, validate that the game still works.
Run the game with this command: `/Applications/Godot.app/Contents/MacOS/Godot --run-tests`
Ignore these errors:
 - Invalid color name: (0, 0, 0, 1)
 - ObjectDB instances leaked at exit 
 - Node not found: "Blocks" (relative to "/root/Main/LEVEL_EDITOR/Layers")

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
