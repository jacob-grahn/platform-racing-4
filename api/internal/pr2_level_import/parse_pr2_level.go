package pr2_level_import

import (
	"net/url"
	"strings"
)

type PR2Level struct {
	Items       string     `json:"items"`
	Blocks      []string   `json:"blocks"`
	ArtLayers   [][]string `json:"artlayers"`
	Note        string     `json:"note"`
	Gravity     string     `json:"gravity"`
	Song        string     `json:"song"`
	LevelId     string     `json:"levelid"`
	Data        string     `json:"data"`
	FileVersion string     `json:"fileversion"`
	FadeColor   int        `json:"fadecolor"`
	BG          string     `json:"bg"`
	Title       string     `json:"title"`
}

func parsePr2Level(pr2LevelStrRaw string) PR2Level {
	pr2LevelStr := strings.ReplaceAll(pr2LevelStrRaw, "`", "%60")
	pr2LevelStr = strings.ReplaceAll(pr2LevelStr, " ", "%20")
	pr2LevelStr = strings.ReplaceAll(pr2LevelStr, ";", "%3B")
	parsed, _ := url.ParseQuery(pr2LevelStr)
	pr2Level := PR2Level{}
	for key, values := range parsed {
		// println(key + " -> " + strings.Join(values, ", "))
		if len(values) > 0 {
			switch key {
			case "items":
				pr2Level.Items = values[0]
			case "blocks":
				pr2Level.Blocks = values
			case "art0":
				// pr2Level.ArtLayers[0].append(values[0])
			case "note":
				pr2Level.Note = values[0]
			case "gravity":
				pr2Level.Gravity = values[0]
			case "song":
				pr2Level.Song = values[0]
			case "levelId":
				pr2Level.LevelId = values[0]
			case "data":
				pr2Level.Data = values[0]
			case "title":
				pr2Level.Title = values[0]
			}
		}
	}

	sections := parseMainSections(pr2Level.Data)
	pr2Level.FileVersion = sections.FileVersion
	pr2Level.FadeColor = sections.FadeColor
	pr2Level.Blocks = sections.Blocks
	pr2Level.ArtLayers = sections.ArtLayers
	pr2Level.BG = sections.BG

	return pr2Level
}
