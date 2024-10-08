package pr2_level_import

import (
	"reflect"
	"strings"
	"testing"
)

func TestParseMainSections(t *testing.T) {
	arr := []string{"m0", "FFFFFF", "blocks", "objects1", "objects2", "objects3", "art1", "art2", "art3", "bg"}
	str := strings.Join(arr, "`")
	str += "32charhashwwwwwwwwwwwwwwwwwwwwww"
	expected := PR2LevelSections{
		Hash:        "32charhashwwwwwwwwwwwwwwwwwwwwww",
		FileVersion: "m0",
		FadeColor:   16777215,
		Blocks:      []string{"blocks"},
		ArtLayers:   [][]string{{"objects1"}, {"objects2"}, {"objects3"}, {"art1"}, {"art2"}, {"art3"}},
		BG:          "bg",
	}

	sections := parseMainSections(str)
	if !reflect.DeepEqual(sections, expected) {
		t.Errorf("Expected %v, got %v", expected, sections)
	}
}
