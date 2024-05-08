package pr2_level_import

import (
	"strconv"
	"strings"
)

// rightPad adds characters to the end of a string up to the desired length
func rightPad(str, pad string, length int) string {
	for len(str) < length {
		str += pad
	}
	return str
}

// parseLine converts PR2's line format into an array of x, y coordinates
func parseLine(lineStr, color string, thickness int, mode string) ArtObject {
	values := strings.Split(lineStr, ";")
	var startX, _ = strconv.Atoi(values[0])
	var startY, _ = strconv.Atoi(values[1])
	var polyline []Point
	var x int = 0
	var y int = 0

	for i := 0; i < len(values); i += 2 {
		valueX, _ := strconv.Atoi(values[i])
		valueY, _ := strconv.Atoi(values[i+1])
		if i == 0 {
			polyline = append(polyline, Point{X: 0, Y: 0})
			continue
		}
		x += valueX
		y += valueY
		polyline = append(polyline, Point{X: x, Y: y})
	}

	return ArtObject{
		X:        startX,
		Y:        startY,
		Polyline: polyline,
		Properties: LineProperties{
			Color:     rightPad(color, "0", 6),
			Thickness: thickness,
			Mode:      mode,
		},
	}
}
