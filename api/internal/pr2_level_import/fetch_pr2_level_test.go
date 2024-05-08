package pr2_level_import

import (
	"strings"
	"testing"
)

func TestFetchPr2Level(t *testing.T) {
	expectedSubstring := "&title=Newbieland 2"
	content, err := fetchPr2Level(50815)
	if err != nil {
		t.Fatalf("Error fetching PR2 level: %s", err)
	}

	if !strings.Contains(content, expectedSubstring) {
		t.Errorf("Fetched content does not contain expected substring '%s'", expectedSubstring)
	}
}
