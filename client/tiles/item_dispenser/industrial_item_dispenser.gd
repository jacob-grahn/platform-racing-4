extends ItemDispenser
class_name IndustrialItemDispenser


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(dispense_item)
