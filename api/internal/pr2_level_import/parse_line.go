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
func parseLine(lineStr, color string, thickness int, mode string) Line {
	values := strings.Split(lineStr, ";")
	var startX, _ = strconv.Atoi(values[0])
	var startY, _ = strconv.Atoi(values[1])
	var polyline []Point
	x := 0
	y := 0

	for i := 2; i < len(values); i += 2 {
		valueX, _ := strconv.Atoi(values[i])
		valueY, _ := strconv.Atoi(values[i+1])
		if valueX != 0 || valueY != 0 {
			x += valueX
			y += valueY
			polyline = append(polyline, Point{
				X: float64(x),
				Y: float64(y),
			})
		}
	}

	return Line{
		X:         float64(startX),
		Y:         float64(startY),
		Points:    polyline,
		Color:     rightPad(color, "0", 6),
		Thickness: thickness,
		Mode:      mode,
	}
}
