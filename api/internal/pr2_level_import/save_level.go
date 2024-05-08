package pr2_level_import

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
)

// saveLevel saves a level configuration to a JSON file
func saveLevel(levelId int, PR4Level interface{}) error {
	path := fmt.Sprintf("pr2/levels/%d/%d.json", levelId, levelId)
	strLevel, err := json.Marshal(PR4Level)
	if err != nil {
		return err
	}
	// Ensure the directory exists
	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		return err
	}
	// Write data to file
	return ioutil.WriteFile(path, strLevel, 0644)
}
