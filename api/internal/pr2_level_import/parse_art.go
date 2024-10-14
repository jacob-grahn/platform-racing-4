package pr2_level_import

import "strconv"

type ArtObject struct {
	X          int            `json:"x"`
	Y          int            `json:"y"`
	Width      int            `json:"width"`
	Height     int            `json:"height"`
	GID        int            `json:"gid"`
	Polyline   []Point        `json:"polyline"`
	Properties LineProperties `json:"properties"`
}

type Point struct {
	X int `json:"x"`
	Y int `json:"y"`
}

type LineProperties struct {
	Color     string `json:"color"`
	Thickness int    `json:"thickness"`
	Mode      string `json:"mode"`
}

func parseArt(artArr []string) Layer {
	color := "000000"
	mode := "draw"
	thickness := 1
	objects := []ArtObject{}

	for _, command := range artArr {
		if command == "" {
			continue
		}
		typeCmd := command[:1]
		content := command[1:]

		switch typeCmd {
		case "c":
			color = content
		case "t":
			thick, _ := strconv.Atoi(content)
			thickness = thick
		case "d":
			objects = append(objects, parseLine(content, color, thickness, mode))
		case "m":
			mode = content
		default:
			// objects = append(objects, parseStamp(command))
		}
	}

	return Layer{
		DrawOrder: "topdown",
		Name:      "artlayer",
		Objects:   objects,
		OffsetX:   0,
		OffsetY:   0,
		Opacity:   1,
		Type:      "objectgroup",
		Visible:   true,
	}
}
