extends ItemDispenser
class_name ClassicItemDispenser


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(dispense_item)
