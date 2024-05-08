package pr2_level_import

import (
	"fmt"
	"io"
	"net/http"
)

func fetchPr2Level(levelId int) (string, error) {
	levelUrl := fmt.Sprintf("%s/%d.txt", baseURL, levelId)
	response, err := http.Get(levelUrl)
	if err != nil {
		return "", err
	}
	defer response.Body.Close()

	// Check if the status code is not 200 OK
	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("unexpected status code: %d %s", response.StatusCode, response.Status)
	}

	data, err := io.ReadAll(response.Body)
	if err != nil {
		return "", err
	}

	return string(data), nil
}
