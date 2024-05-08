package pr2_level_import

import (
	"reflect"
	"testing"
)

func TestParseArt(t *testing.T) {
	artArr := []string{"d10155;10082;0;-7;0;-13"}
	group := parseArt(artArr)

	expectedObjects := []ArtObject{{
		X: 10155,
		Y: 10082,
		Polyline: []Point{
			{X: 0, Y: 0},
			{X: 0, Y: -7},
			{X: 0, Y: -20},
		},
		Properties: LineProperties{
			Color:     "000000",
			Thickness: 1,
			Mode:      "draw",
		},
	}}

	if !reflect.DeepEqual(group.Objects, expectedObjects) {
		t.Errorf("Expected %+v, got %+v", expectedObjects, group.Objects)
	}
}
