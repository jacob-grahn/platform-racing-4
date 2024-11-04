package pr2_level_import

import (
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
)

func fetchPr2Level(levelId int) (string, error) {
	levelUrl := fmt.Sprintf("%s/levels/%d.txt", baseURL, levelId)

	response, err := http.Get(levelUrl)
	if err != nil {
		return "", err
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("unexpected status code: %d %s", response.StatusCode, response.Status)
	}

	data, err := io.ReadAll(response.Body)
	if err != nil {
		return "", err
	}

	return string(data), nil
}

func listPr2Levels(levelType string, page string) (string, error) {
	url := fmt.Sprintf("%s/files/lists/%s/%s", baseURL, levelType, page)

	response, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("unexpected status code: %d %s", response.StatusCode, response.Status)
	}

	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return "", err
	}

	return string(body), nil
}
