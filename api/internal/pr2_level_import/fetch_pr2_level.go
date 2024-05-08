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

	data, err := io.ReadAll(response.Body)
	if err != nil {
		return "", err
	}

	return string(data), nil
}
