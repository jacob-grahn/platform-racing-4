package pr2_level_import

import (
	"os"
	"path/filepath"
	"testing"
)

func TestParsePr2Level(t *testing.T) {
	filepath := filepath.Join("./", "50815.txt")
	pr2LevelStr, err := os.ReadFile(filepath)
	if err != nil {
		t.Fatal("Failed to read test file:", err)
	}
	pr2Level := parsePr2Level(string(pr2LevelStr))
	// expectedKeys := []string{"credits", "gameMode", "gravity", "has_pass", "items", "level_id", "live", "max_time", "min_level", "note", "song", "time", "title", "user_id", "version", "fileVersion", "fadeColor", "blocks", "u1", "u2", "bg", "artLayers"}
	if pr2Level.Title != "Newbieland 2" {
		t.Errorf("Expected Title to be 'Newbieland 2', got %s", pr2Level.Title)
	}
	if pr2Level.BG != "204" {
		t.Errorf("Expected BG to be '204', got %s", pr2Level.BG)
	}
}
