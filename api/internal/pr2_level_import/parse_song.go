package pr2_level_import

func parseMusic(music string) string {
	if music == "1" {
		return "orbital-trance"
	}
	if music == "2" {
		return "code"
	}
	if music == "3" {
		return "paradise-on-e"
	}
	if music == "4" {
		return "crying-soul"
	}
	if music == "5" {
		return "my-vision"
	}
	if music == "6" {
		return "switchblade"
	}
	if music == "7" {
		return "the-wires"
	}
	if music == "8" {
		return "before-mydnite"
	}
	if music == "9" { // 9 was removed
		return ""
	}
	if music == "10" {
		return "broked-it"
	}
	if music == "11" {
		return "hello"
	}
	if music == "12" {
		return "pyrokinesis"
	}
	if music == "13" {
		return "flowerz-n-herbz"
	}
	if music == "14" {
		return "instrumental-4"
	}
	if music == "15" {
		return "prismatic"
	}
	if music == "16" { // 16 was removed
		return ""
	}
	if music == "17" {
		return "oodaloo"
	}
	if music == "18" {
		return "night-shade"
	}
	if music == "19" {
		return "blizzard"
	}
	if music == "20" {
		return "pasture-instrumental"
	}
	if music == "21" {
		return "sunset-raiders"
	}

	return "" // returning an empty string = a random music
}
