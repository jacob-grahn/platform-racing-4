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

func TestFetchPr2Level_Non200StatusCode(t *testing.T) {
	_, err := fetchPr2Level(123) // Assume 123 is an ID that results in a non-200 response
	if err == nil {
		t.Error("Expected an error for non-200 HTTP status code, but got none")
	}
}
