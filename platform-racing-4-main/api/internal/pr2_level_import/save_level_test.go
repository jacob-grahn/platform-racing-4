package pr2_level_import

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

func TestSaveLevel(t *testing.T) {
	levelId := 555
	PR4Level := "somelevel"

	// Temporarily change the working directory to a test directory
	oldDir, _ := os.Getwd()
	testDir := filepath.Join(oldDir, "testdir")
	os.MkdirAll(testDir, 0755)
	os.Chdir(testDir)
	defer func() {
		os.Chdir(oldDir)
		os.RemoveAll(testDir)
	}()

	// Execute the function
	if err := saveLevel(levelId, PR4Level); err != nil {
		t.Fatalf("Failed to save level: %v", err)
	}

	// Verify the file
	expectedPath := fmt.Sprintf("pr2/levels/%d/%d.json", levelId, levelId)
	expectedData, _ := json.Marshal(PR4Level)
	data, err := ioutil.ReadFile(expectedPath)
	if err != nil {
		t.Fatalf("Failed to read back the saved file: %v", err)
	}

	if string(data) != string(expectedData) {
		t.Errorf("Data in file %s did not match expected. Got %s, want %s", expectedPath, data, expectedData)
	}
}
