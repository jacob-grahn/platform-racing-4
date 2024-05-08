package pr2_level_import

type StampData struct {
	ImageHeight float64
	ImageWidth  float64
}

/*

import (
	"strconv"
	"strings"
)

// Global variables simulating module-level state in JS
var (
	scaleFactor = 0.450160772
	x           = 0.0
	y           = 0.0
	stampId     = "0"
)

func parseStamp(command string) ArtObject {
	segs := strings.Split(command, ";")
	if len(segs) == 4 {
		segs = append(segs[:2], append([]string{stampId}, segs[2:]...)...)
	}

	shiftX, _ := strconv.ParseFloat(segs[0], 64)
	shiftY, _ := strconv.ParseFloat(segs[1], 64)
	nextStampId := stampId
	if len(segs) > 2 {
		nextStampId = segs[2]
	}
	scaleX, scaleY := 100.0, 100.0
	if len(segs) > 3 {
		scaleX, _ = strconv.ParseFloat(segs[3], 64)
	}
	if len(segs) > 4 {
		scaleY, _ = strconv.ParseFloat(segs[4], 64)
	}
	stampId = nextStampId

	gid := float64(stampTileset.FirstGid) + parseFloat(stampId)
	stampData := stampTileset.Tiles[stampId]
	width := scaleX * stampData.ImageWidth * 0.01 * scaleFactor
	height := scaleY * stampData.ImageHeight * 0.01 * scaleFactor

	x += shiftX
	y += shiftY + height

	return ArtObject{
		GID:    int(gid),
		X:      int(x),
		Y:      int(y),
		Width:  int(width),
		Height: int(height),
	}
}
*/
