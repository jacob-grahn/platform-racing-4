## This file is deprecated, to not add fields to it
## If possible, remove fields from it!

extends Node

# The layers global is used to manage the layers in the game.
var layers: Node
# The minimaps global is used to display the minimaps in the UI.
var minimaps: Node
func clear():
	layers = null
	minimaps = null
