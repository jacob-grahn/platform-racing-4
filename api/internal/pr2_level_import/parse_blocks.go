package pr2_level_import

import (
	"math"
	"strconv"
	"strings"
)

type TileLayer struct {
	Opacity int
	StartX  int
	StartY  int
	Type    string
	Name    string
	Visible bool
	OffsetX int
	OffsetY int
	Width   int
	Height  int
	X       int
	Y       int
	Chunks  []Chunk
}

type Chunk struct {
	Data   []int
	Width  int
	Height int
	X      int
	Y      int
}

func parseBlocks(blockArr []string, chunkSize int) TileLayer {
	chunkDict := make(map[string]Chunk)
	x, y, tileId := 0, 0, 0

	for _, command := range blockArr {
		parts := strings.Split(command, ";")
		moveX, _ := strconv.Atoi(parts[0])
		moveY, _ := strconv.Atoi(parts[1])
		if len(parts) > 2 {
			newTileId, _ := strconv.Atoi(parts[2])
			if newTileId >= 100 {
				tileId = newTileId - 99
			} else {
				tileId = newTileId + 1
			}
		}
		x += moveX
		y += moveY
		placeTile(chunkDict, chunkSize, x, y, tileId)
	}

	minX, minY := math.MaxInt64, math.MaxInt64
	maxX, maxY := math.MinInt64, math.MinInt64
	for _, chunk := range chunkDict {
		minX = min(minX, chunk.X)
		minY = min(minY, chunk.Y)
		maxX = max(maxX, chunk.X+chunkSize)
		maxY = max(maxY, chunk.Y+chunkSize)
	}

	chunks := []Chunk{}
	for _, value := range chunkDict {
		chunks = append(chunks, value)
	}

	return TileLayer{
		Opacity: 1,
		StartX:  0,
		StartY:  0,
		Type:    "tilelayer",
		Name:    "tilelayer",
		Visible: true,
		OffsetX: 0,
		OffsetY: 0,
		Width:   maxX - minX,
		Height:  maxY - minY,
		X:       minX,
		Y:       minY,
		Chunks:  chunks,
	}
}
