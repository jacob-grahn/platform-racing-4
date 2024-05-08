package pr2_level_import

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type Layer interface{}

type PR4Level struct {
	BackgroundColor string
	Width           int
	Height          int
	Infinite        bool
	Layers          []Layer
	Orientation     string
	TileHeight      int
	TileWidth       int
	TiledVersion    string
	Properties      map[string]interface{}
	Tilesets        []Tileset
}

type Tileset struct {
	FirstGid int
	Name     string
	Tiles    map[string]StampData
}

const baseURL = "https://pr2hub.com/levels"

func SetupPR2LevelImportRoutes(router *gin.Engine, db *gorm.DB) {
	router.GET("/pr2/level/:id", func(c *gin.Context) {
		idStr := c.Param("id")

		id, err := strconv.Atoi(idStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}

		result, err := importPr2Level(id)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Level not found"})
			return
		}
		c.JSON(http.StatusOK, result)
	})
}

func importPr2Level(levelId int) (interface{}, error) {
	pr2LevelStr, err := fetchPr2Level(levelId)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch PR2 level: %w", err)
	}

	pr2Level := parsePr2Level(pr2LevelStr)
	pr4Level := pr2ToPr4(pr2Level)

	/*err = saveLevel(levelId, pr4Level)
	if err != nil {
		return nil, fmt.Errorf("failed to save PR2 level: %w", err)
	}*/

	return pr4Level, nil
}

func safeSplit(str string) []string {
	if str == "" {
		return []string{}
	}
	return strings.Split(str, ",")
}

func makeChunk(chunkSize, x, y int) Chunk {
	data := make([]int, chunkSize*chunkSize)
	return Chunk{Data: data, Width: chunkSize, Height: chunkSize, X: x, Y: y}
}

func placeTile(chunkDict map[string]Chunk, chunkSize, x, y, tileId int) {
	chunkX := (x / chunkSize) * chunkSize
	chunkY := (y / chunkSize) * chunkSize
	innerX := x % chunkSize
	innerY := y % chunkSize
	pos := innerY*chunkSize + innerX
	chunkId := strconv.Itoa(chunkX) + "," + strconv.Itoa(chunkY)

	_, ok := chunkDict[chunkId]
	if !ok {
		chunkDict[chunkId] = makeChunk(chunkSize, chunkX, chunkY)
	}
	chunkDict[chunkId].Data[pos] = tileId
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func parseFloat(s string) float64 {
	f, _ := strconv.ParseFloat(s, 64)
	return f
}
