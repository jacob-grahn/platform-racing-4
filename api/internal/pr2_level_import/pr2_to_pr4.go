package pr2_level_import

func pr2ToPr4(PR2Level PR2Level) PR4Level {
	artLayers := make([]Layer, len(PR2Level.ArtLayers))
	for i, layer := range PR2Level.ArtLayers {
		artLayers[i] = parseArt(layer) // Assuming parseArt returns a Layer
	}

	// Applying parallax settings
	// Be mindful that actual parallax logic would require the Layer to be a specific struct that can hold this property.
	// For simplicity, this is conceptual.

	return PR4Level{
		BackgroundColor: "#FFFFFF",
		Width:           100,
		Height:          100,
		Infinite:        true,
		Layers:          append([]Layer{parseBlocks(PR2Level.Blocks, 4)}, artLayers...),
		Orientation:     "orthogonal",
		TileHeight:      30,
		TileWidth:       30,
		TiledVersion:    "1.1.5",
		Properties: map[string]interface{}{
			"items":   parseItems(PR2Level.Items),
			"note":    PR2Level.Note,
			"gravity": parseFloat(PR2Level.Gravity),
			"song":    parseFloat(PR2Level.Song),
			"levelId": parseFloat(PR2Level.LevelId),
		},
		Tilesets: []Tileset{
			{FirstGid: 1, Name: "blocks"},
			{FirstGid: 2, Name: "stamps"},
		},
	}
}
