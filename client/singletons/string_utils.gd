extends Node
## Provides utility functions for string manipulation and generation.

func generate_uuidv4() -> String:
	var uuid := []
	for i in range(16):
		uuid.append(randi() % 256)

	uuid[6] = (uuid[6] & 0x0F) | 0x40
	uuid[8] = (uuid[8] & 0x3F) | 0x80
	
	return format_uuid(uuid)


func format_uuid(uuid: Array) -> String:
	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % uuid


func generate_username() -> String:
	var adjectives := ["Bold", "Fast", "Keen", "Wise", "Nimble", "Vast"]
	var nouns := ["Fox", "Hawk", "Mage", "Wolf", "Drake", "Scout"]
	var adjective: String = adjectives[randi() % adjectives.size()]
	var noun: String = nouns[randi() % nouns.size()]
	var number := str(randi() % 100)  # Limit to two digits to keep it shorter
	return adjective + noun + number
