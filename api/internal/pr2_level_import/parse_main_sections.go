package pr2_level_import

import "strings"

type PR2LevelSections struct {
	FileVersion string     `json:"fileversion"`
	FadeColor   string     `json:"fadecolor"`
	Blocks      []string   `json:"blocks"`
	ArtLayers   [][]string `json:"artlayers"`
	BG          string     `json:"bg"`
}

func parseMainSections(str string) PR2LevelSections {
	mainSections := strings.Split(str, "`")
	return PR2LevelSections{
		FileVersion: mainSections[0],
		FadeColor:   mainSections[1],
		Blocks:      safeSplit(mainSections[2]),
		ArtLayers: [][]string{
			safeSplit(mainSections[8]), // art00
			safeSplit(mainSections[7]), // art0
			safeSplit(mainSections[3]), // art1
			safeSplit(mainSections[4]), // art2
			safeSplit(mainSections[5]), // art3
			safeSplit(mainSections[6]), // art4
		},
		BG: mainSections[9],
	}
}
