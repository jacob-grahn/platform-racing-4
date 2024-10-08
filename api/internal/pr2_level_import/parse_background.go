package pr2_level_import

func parseBackground(bg string) string {
	if bg == "BG1" || bg == "201" {
		return "field"
	}
	if bg == "BG2" || bg == "202" {
		return "generic"
	}
	if bg == "BG3" || bg == "203" {
		return "lake"
	}
	if bg == "BG4" || bg == "204" {
		return "desert"
	}
	if bg == "BG5" || bg == "205" {
		return "dots"
	}
	if bg == "BG6" || bg == "206" {
		return "space"
	}
	if bg == "BG7" || bg == "207" {
		return "skyscraper"
	}

	return "field"
}
