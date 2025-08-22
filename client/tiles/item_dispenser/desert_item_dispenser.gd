extends ItemDispenser
class_name DesertItemDispenser


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(dispense_item)
