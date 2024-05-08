package pr2_level_import

import (
	"reflect"
	"strings"
	"testing"
)

func TestParseMainSections(t *testing.T) {
	arr := []string{"fileVersion", "fadeColor", "blocks", "art1", "art2", "art3", "art4", "u1", "u2", "bg"}
	str := strings.Join(arr, "`")
	expected := PR2LevelSections{
		FileVersion: "fileVersion",
		FadeColor:   "fadeColor",
		Blocks:      []string{"blocks"},
		ArtLayers:   [][]string{{"u2"}, {"u1"}, {"art1"}, {"art2"}, {"art3"}, {"art4"}},
		BG:          "bg",
	}

	sections := parseMainSections(str)
	if !reflect.DeepEqual(sections, expected) {
		t.Errorf("Expected %v, got %v", expected, sections)
	}
}
