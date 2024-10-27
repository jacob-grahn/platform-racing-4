package pr2_level_import

func pr2ToPr4(PR2Level PR2Level) PR4Level {
	artLayers := make([]Layer, len(PR2Level.ArtLayers))
	for i, layer := range PR2Level.ArtLayers {
		artLayers[i] = parseArt(layer) // Assuming parseArt returns a Layer
	}

	blockLayer := parseBlocks(PR2Level.Blocks, 8)
	combinedLayers := []Layer{}

	if len(artLayers) >= 6 {
		combinedLayers = []Layer{
			{
				Name:  "Art 1",
				Lines: artLayers[0].Lines,
				//Objects: artLayers[3].Objects,
				Depth: 10,
				Scale: upscaleRatio,
			},
			{
				Name:   "Blocks",
				Chunks: blockLayer.Chunks,
				Depth:  10,
				Scale:  1,
			},
			{
				Name:  "Art 2",
				Lines: artLayers[1].Lines,
				//Objects: append(artLayers[1].Objects, artLayers[4].Objects...),
				Depth: 5,
				Scale: upscaleRatio,
			},
			{
				Name:  "Art 3",
				Lines: artLayers[2].Lines,
				//Objects: append(artLayers[2].Objects, artLayers[5].Objects...),
				Depth: 2, // 2.5
				Scale: upscaleRatio,
			},
		}
	}

	if len(artLayers) >= 10 {
		combinedLayers = append(combinedLayers,
			Layer{
				Name:  "Art 0",
				Lines: artLayers[6].Lines,
				//Objects: append(artLayers[6].Objects, artLayers[8].Objects...),
				Depth: 10,
				Scale: upscaleRatio,
			},
			Layer{
				Name:  "Art 00",
				Lines: artLayers[7].Lines,
				//Objects: append(artLayers[7].Objects, artLayers[9].Objects...),
				Depth: 16, // 20
				Scale: upscaleRatio,
			},
		)
	}

	return PR4Level{
		BackgroundColor: "#FFFFFF",
		Width:           100, // what is this for?
		Height:          100, // what is this for?
		Infinite:        true,
		Layers:          combinedLayers,
		Orientation:     "orthogonal",
		TileHeight:      128,
		TileWidth:       128,
		TiledVersion:    "1.1.5",
		Properties: map[string]interface{}{
			"items":      parseItems(PR2Level.Items),
			"note":       PR2Level.Note,
			"gravity":    parseFloat(PR2Level.Gravity),
			"music":      parseMusic(PR2Level.Song),
			"levelId":    parseFloat(PR2Level.LevelId),
			"background": parseBackground(PR2Level.BG),
			"fadeColor":  PR2Level.FadeColor,
		},
		Tilesets: []Tileset{
			{FirstGid: 1, Name: "blocks"},
			{FirstGid: 2, Name: "stamps"},
		},
	}
}
