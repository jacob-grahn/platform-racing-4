package pr2_level_import

import (
	"reflect"
	"testing"
)

func TestParseLine(t *testing.T) {
	lineStr := "30;27;12;15"
	color := "0"
	thickness := 5
	mode := "paintbrush"

	expected := ArtObject{
		X: 30,
		Y: 27,
		Polyline: []Point{
			{X: 0, Y: 0},
			{X: 12, Y: 15},
		},
		Properties: LineProperties{
			Color:     "000000",
			Thickness: thickness,
			Mode:      mode,
		},
	}

	result := parseLine(lineStr, color, thickness, mode)
	if !reflect.DeepEqual(result, expected) {
		t.Errorf("Expected %+v, got %+v", expected, result)
	}
}
