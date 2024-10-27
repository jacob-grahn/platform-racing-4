package pr2_level_import

import (
	"os"
	"path/filepath"
	"testing"
)

func TestPr2ToPr4(t *testing.T) {
	result := pr2ToPr4(PR2Level{})
	if len(result.Tilesets) != 2 {
		t.Errorf("Expected 2 tilesets, got %d", len(result.Tilesets))
	}

	PR2Level := PR2Level{
		Items:   "boat`plane",
		Song:    "1",
		Gravity: "0.8",
	}
	result = pr2ToPr4(PR2Level)
	properties := result.Properties
	if items, ok := properties["items"].([]string); !ok || len(items) != 2 {
		t.Errorf("Expected items to have 2 elements, got %v", properties["items"])
	}
	if properties["music"] != "orbital-trance" {
		t.Errorf("Expected music to be 'orbital-trance', got %v", properties["music"])
	}
	if properties["gravity"].(float64) != 0.8 {
		t.Errorf("Expected gravity to be 0.8, got %v", properties["gravity"])
	}
}

func TestPr2ToPr4Newbieland(t *testing.T) {
	filepath := filepath.Join("./", "50815.txt")
	pr2LevelStr, err := os.ReadFile(filepath)
	if err != nil {
		t.Fatal("Failed to read test file:", err)
	}
	pr2Level := parsePr2Level(string(pr2LevelStr))

	result := pr2ToPr4(pr2Level)

	if result.Layers[2].Lines == nil {
		t.Errorf("Expected layer 0 to have lines, got %v", result.Layers[0].Lines)
	}
}
