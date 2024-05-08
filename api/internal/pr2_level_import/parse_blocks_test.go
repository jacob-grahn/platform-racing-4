package pr2_level_import

import (
	"reflect"
	"testing"

	"github.com/go-playground/assert/v2"
)

func TestParseBlocks(t *testing.T) {
	blocks := []string{"334;335;11", "-6;-4;0", "1;0"}
	tileLayer := parseBlocks(blocks, 16)
	expectedChunks := []Chunk{
		{
			Data: []int{
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 0,
			},
			Height: 16,
			Width:  16,
			X:      320,
			Y:      320,
		},
	}

	if !reflect.DeepEqual(tileLayer.Chunks, expectedChunks) {
		t.Errorf("Expected %+v, got %+v", expectedChunks, tileLayer.Chunks)
	}
}

func TestBlockLayerDimensions(t *testing.T) {
	blocks := []string{
		"334;335;11",
		"-6;4;0",
		"1;0",
	}

	chunkSize := 4
	result := parseBlocks(blocks, chunkSize)
	assert.Equal(t, 8, result.Width)
	assert.Equal(t, 8, result.Height)
	assert.Equal(t, 328, result.X)
	assert.Equal(t, 332, result.Y)
	assert.Equal(t, 0, result.OffsetX)
	assert.Equal(t, 0, result.OffsetY)
}
