package pr2_level_import

import (
	"fmt"
	"strconv"
	"strings"
)

type PR2LevelSections struct {
	Hash        string     `json:"hash"`
	FileVersion string     `json:"fileversion"`
	FadeColor   int        `json:"fadecolor"`
	Blocks      []string   `json:"blocks"`
	ArtLayers   [][]string `json:"artlayers"`
	BG          string     `json:"bg"`
}

const defaultSegSize = 1
const segSize = 30

func parseMainSections(fullLevelStr string) PR2LevelSections {
	// Extract the hash and the level data
	hashPos := len(fullLevelStr) - 32
	levelHash := fullLevelStr[hashPos:]
	levelStr := fullLevelStr[:hashPos]

	// split on ` for main sections
	levelData := strings.Split(levelStr, "`")
	readMode := levelData[0]

	// handle different level readModes
	levelData = levelData[1:]
	levelData[0] = convertHexToNumber(levelData[0])
	if readMode == "m1" || readMode == "m2" || readMode == "m3" || readMode == "m4" {
		if readMode == "m1" {
			levelData[1] = decodeObjectString(levelData[1])
			levelData[2] = decodeObjectString(levelData[2])
			levelData[3] = decodeObjectString(levelData[3])
			levelData[4] = decodeObjectString(levelData[4])
		} else if readMode == "m2" || readMode == "m3" || readMode == "m4" {
			if readMode == "m2" {
				levelData[1] = decodeObjectString2(levelData[1], defaultSegSize) // blocks
			} else if readMode == "m3" {
				levelData[1] = decodeObjectString2(levelData[1], segSize) // blocks
			} else {
				levelData[1] = decodeBlockString(levelData[1])
			}
			levelData[2] = decodeObjectString2(levelData[2], defaultSegSize) // art1
			levelData[3] = decodeObjectString2(levelData[3], defaultSegSize) // art2
			levelData[4] = decodeObjectString2(levelData[4], defaultSegSize) // art3
			if len(levelData) > 10 {
				levelData[9] = decodeObjectString2(levelData[9], defaultSegSize)   // art0
				levelData[10] = decodeObjectString2(levelData[10], defaultSegSize) // art00
			}
		}
	}

	artLayers := [][]string{
		safeSplit(levelData[2]), // objects1
		safeSplit(levelData[3]), // objects2
		safeSplit(levelData[4]), // objects3
		safeSplit(levelData[5]), // lines1
		safeSplit(levelData[6]), // lines3
		safeSplit(levelData[7]), // lines2
	}

	if len(levelData) > 10 {
		artLayers = append(artLayers,
			safeSplit(levelData[9]),  // objects0
			safeSplit(levelData[10]), // objects00
			safeSplit(levelData[11]), // lines0
			safeSplit(levelData[12]), // lines00
		)
	}

	fadeColor, err := strconv.Atoi(levelData[0])
	if err != nil {
		fmt.Println("Error:", err)
	}

	return PR2LevelSections{
		Hash:        levelHash,
		FileVersion: readMode,
		FadeColor:   fadeColor,
		Blocks:      safeSplit(levelData[1]),
		BG:          levelData[8],
		ArtLayers:   artLayers,
	}
}

// Convert the hexadecimal string to a number
func convertHexToNumber(hexValue string) string {
	number, err := strconv.ParseInt(hexValue, 16, 64)
	if err != nil {
		fmt.Println("Error converting hex to number:", err)
		return "0"
	}

	return fmt.Sprintf("%d", number)
}

func decodeObjectString(objectString string) string {
	dataArr := strings.Split(objectString, ",")
	thisObj := strings.Split(dataArr[0], ";")
	dataArr = dataArr[1:] // shift, remove first element from dataArr

	_local_4, _ := strconv.ParseInt(thisObj[0], 16, 64)
	_local_5, _ := strconv.ParseInt(thisObj[1], 16, 64)

	for i := 0; i < len(dataArr); i++ {
		thisObj = strings.Split(dataArr[i], ";")
		_local_13, _ := strconv.ParseInt(thisObj[0], 16, 64)
		_local_9, _ := strconv.ParseInt(thisObj[1], 16, 64)
		_local_9 += _local_4
		_local_10, _ := strconv.ParseInt(thisObj[2], 16, 64)
		_local_10 += _local_5

		dataArr[i] = fmt.Sprintf("o%d;%d;%d", _local_13, _local_9, _local_10)

		if len(thisObj) > 3 {
			_local_11, _ := strconv.ParseInt(thisObj[3], 16, 64)
			_local_12, _ := strconv.ParseInt(thisObj[4], 16, 64)
			_local_11F := float64(_local_11) / 100.0
			_local_12F := float64(_local_12) / 100.0

			dataArr[i] += fmt.Sprintf(";%f;%f", _local_11F, _local_12F)
		}
	}

	return strings.Join(dataArr, ",")
}

func decodeObjectString2(objectString string, segMult int) string {
	if segMult == 0 {
		segMult = 1 // Default value for segMult if not provided
	}

	var widthPerc, heightPerc float64
	dataArr := []string{}

	if objectString != "" {
		dataArr = strings.Split(objectString, ",")
	}

	var decoded string
	var objectCode, currentX, currentY int

	if len(dataArr) > 0 {
		for i := 0; i < len(dataArr); i++ {
			widthPerc, heightPerc = 0, 0
			thisObj := strings.Split(dataArr[i], ";")

			relX, _ := strconv.Atoi(thisObj[0]) // Convert x relative position
			relY, _ := strconv.Atoi(thisObj[1]) // Convert y relative position
			currentX += relX                    // Update x pointer
			currentY += relY                    // Update y pointer

			if len(thisObj) >= 3 && thisObj[2] == "t" { // Process text
				textContent := thisObj[3]
				textColor, _ := strconv.Atoi(thisObj[4])
				widthPerc, _ = strconv.ParseFloat(thisObj[5], 64)
				heightPerc, _ = strconv.ParseFloat(thisObj[6], 64)

				dataArr[i] = fmt.Sprintf("u%s;%d;%d;%d;%.2f;%.2f", textContent, currentX, currentY, textColor, widthPerc, heightPerc)
			} else { // Process other objects
				if len(thisObj) > 4 { // Resizable objects (new object code)
					objectCode, _ = strconv.Atoi(thisObj[2])
					widthPerc, _ = strconv.ParseFloat(thisObj[3], 64)
					widthPerc /= 100
					heightPerc, _ = strconv.ParseFloat(thisObj[4], 64)
					heightPerc /= 100
				} else if len(thisObj) > 3 { // Takes the previous object code
					widthPerc, _ = strconv.ParseFloat(thisObj[2], 64)
					widthPerc /= 100
					heightPerc, _ = strconv.ParseFloat(thisObj[3], 64)
					heightPerc /= 100
				} else if len(thisObj) > 2 { // Blocks (new object code)
					objectCode, _ = strconv.Atoi(thisObj[2])
				}

				dataArr[i] = fmt.Sprintf("o%d;%d;%d", objectCode, currentX*segMult, currentY*segMult)
				if widthPerc != 0 && heightPerc != 0 {
					dataArr[i] += fmt.Sprintf(";%.2f;%.2f", widthPerc, heightPerc)
				}
			}
		}
		decoded = strings.Join(dataArr, ",")
	}

	return decoded
}

func decodeBlockString(blockString string) string {
	dataArr := []string{}
	if blockString != "" {
		dataArr = strings.Split(blockString, ",")
	}

	var decoded string
	var blockCode, currentX, currentY int

	if len(dataArr) > 0 {
		for i := 0; i < len(dataArr); i++ {
			thisBlock := strings.Split(dataArr[i], ";")

			// Parse relative X and Y positions
			relX, _ := strconv.Atoi(thisBlock[0])
			relY, _ := strconv.Atoi(thisBlock[1])

			currentX += relX // Update X pointer
			currentY += relY // Update Y pointer

			// Parse block code
			if len(thisBlock) > 2 && thisBlock[2] != "" {
				blockCode, _ = strconv.Atoi(thisBlock[2])
			}

			// Parse block options
			options := ""
			if len(thisBlock) > 3 && thisBlock[3] != "" {
				options = ";" + thisBlock[3]
			}

			// Construct the decoded string for this block
			dataArr[i] = fmt.Sprintf("o%d;%d;%d%s", blockCode, currentX*segSize, currentY*segSize, options)
		}
		decoded = strings.Join(dataArr, ",")
	}

	return decoded
}
