package pr2_level_import

import "strconv"

type ArtObject struct {
	X          int
	Y          int
	Width      int
	Height     int
	GID        int
	Polyline   []Point
	Properties LineProperties
}

type Point struct {
	X int
	Y int
}

type LineProperties struct {
	Color     string
	Thickness int
	Mode      string
}

type ObjectGroup struct {
	DrawOrder string
	Name      string
	Objects   []ArtObject
	OffsetX   int
	OffsetY   int
	Opacity   int
	Type      string
	Visible   bool
}

func parseArt(artArr []string) ObjectGroup {
	color := "000000"
	mode := "draw"
	thickness := 1
	objects := []ArtObject{}

	for _, command := range artArr {
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

	return ObjectGroup{
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
