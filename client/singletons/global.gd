extends Node

# The editor_cursors global is used to manage the cursors of other players in the level editor.
var editor_cursors: Node
# The layers global is used to manage the layers in the game.
var layers: Node
# The minimaps global is used to display the minimaps in the UI.
var minimaps: Node
# The users_host_edit_panel global is used to manage the host edit panel in the level editor.
var users_host_edit_panel: Node
# The users_join_edit_panel global is used to manage the join edit panel in the level editor.
var users_join_edit_panel: Node
# The users_quit_edit_panel global is used to manage the quit edit panel in the level editor.
var users_quit_edit_panel: Node
func clear():
	editor_cursors = null
	layers = null
	minimaps = null
	users_host_edit_panel = null
	users_join_edit_panel = null
	users_quit_edit_panel = null
