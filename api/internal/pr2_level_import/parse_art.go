package pr2_level_import

import (
	"math"
	"strconv"
)

const MODE_DRAW = "draw"
const MODE_ERASE = "erase"

type Point struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

type Line struct {
	X         float64 `json:"x"`
	Y         float64 `json:"y"`
	Points    []Point `json:"points"`
	Color     string  `json:"color"`
	Thickness int     `json:"thickness"`
	Mode      string  `json:"mode"`
}

func parseArt(artArr []string) Layer {
	color := "000000"
	mode := MODE_DRAW
	thickness := 1
	lines := []Line{}

	for _, command := range artArr {
		if command == "" {
			continue
		}
		typeCmd := command[:1]
		content := command[1:]

		switch typeCmd {
		case "c":
			color = leftPad(content, 6, '0')
		case "t":
			thick, _ := strconv.Atoi(content)
			thickness = thick
		case "d":
			lines = append(lines, parseLine(content, color, thickness, mode))
		case "m":
			mode = content
		default:
			// objects = append(objects, parseStamp(command))
		}
	}

	lines = runEraser(lines)

	return Layer{
		DrawOrder: "topdown",
		Name:      "artlayer",
		Lines:     lines,
		OffsetX:   0,
		OffsetY:   0,
		Opacity:   1,
		Type:      "objectgroup",
		Visible:   true,
	}
}

func runEraser(lines []Line) []Line {
	var drawLines []Line

	// Loop through the lines and erase as we go
	for _, line := range lines {
		if line.Mode == MODE_DRAW {
			drawLines = append(drawLines, line)
		} else {
			// Check if this is a point eraser (no points or just a single point at 0,0)
			if len(line.Points) == 0 || (len(line.Points) == 1 && line.Points[0].X == 0 && line.Points[0].Y == 0) {
				// Use special point-based erasing for point erasers
				eraserX := line.X
				eraserY := line.Y
				eraserRadius := float64(line.Thickness) / 2
				
				drawLines = eraseWithinRadius(drawLines, eraserX, eraserY, eraserRadius)
			} else {
				// Regular line eraser, use line-based erasing
				drawLines = eraseSegmentList(drawLines, line)
			}
		}
	}

	return drawLines
}

// eraseWithinRadius erases any line segments that are fully within a given radius from a point
func eraseWithinRadius(drawLines []Line, x, y, radius float64) []Line {
	var result []Line
	
	for _, drawLine := range drawLines {
		// Convert to global coordinates for easier distance calculation
		globalLine := toGlobalLine(drawLine)
		
		// Check if any points are outside the radius
		pointsOutsideRadius := false
		
		for _, point := range globalLine.Points {
			dx := point.X - x
			dy := point.Y - y
			distance := math.Sqrt(dx*dx + dy*dy)
			
			if distance > radius {
				pointsOutsideRadius = true
				break
			}
		}
		
		// If any points are outside the radius, keep the line
		if pointsOutsideRadius {
			result = append(result, drawLine)
		}
	}
	
	return result
}

// lineIntersects checks if two line segments intersect and returns the intersection point
func lineIntersects(p1, p2, q1, q2 Point) (bool, *Point) {
	// Calculate the direction vectors
	r := Point{X: p2.X - p1.X, Y: p2.Y - p1.Y}
	s := Point{X: q2.X - q1.X, Y: q2.Y - q1.Y}

	// Calculate the denominator
	denominator := r.X*s.Y - r.Y*s.X

	// If denominator is 0, lines are parallel or collinear
	if math.Abs(denominator) < 1e-10 {
		return false, nil
	}

	// Calculate parameters for the intersection point
	t := ((q1.X-p1.X)*s.Y - (q1.Y-p1.Y)*s.X) / denominator
	u := ((q1.X-p1.X)*r.Y - (q1.Y-p1.Y)*r.X) / denominator

	// Check if intersection occurs within both line segments
	if t >= 0 && t <= 1 && u >= 0 && u <= 1 {
		// Calculate intersection point
		intersectionPoint := &Point{
			X: p1.X + t*r.X,
			Y: p1.Y + t*r.Y,
		}
		return true, intersectionPoint
	}

	return false, nil
}

// Represent a line in global coordinates
// will tend to be full of large numbers, but easier to do math with
func toGlobalLine(localLine Line) Line {
	globalLine := Line{
		X: 0,
		Y: 0,
		Points: []Point{
			{
				X: localLine.X,
				Y: localLine.Y,
			},
		},
		Thickness: localLine.Thickness,
		Color:     localLine.Color,
	}

	for _, point := range localLine.Points {
		globalLine.Points = append(globalLine.Points, Point{
			X: point.X + localLine.X,
			Y: point.Y + localLine.Y,
		})
	}

	return globalLine
}

// Represent a line in a theretically more compact form
func toLocalLine(globalLine Line) Line {
	if len(globalLine.Points) == 0 {
		return Line{} // return an empty Line if there are no points
	}

	// The local origin is the first point in the globalLine
	localX := globalLine.Points[0].X
	localY := globalLine.Points[0].Y

	// Initialize the local line with the origin point and other attributes
	localLine := Line{
		X:         localX,
		Y:         localY,
		Thickness: globalLine.Thickness,
		Color:     globalLine.Color,
	}

	// Adjust each point relative to the local origin
	for _, point := range globalLine.Points[1:] {
		localLine.Points = append(localLine.Points, Point{
			X: point.X - localX,
			Y: point.Y - localY,
		})
	}

	return localLine
}

func eraseSegmentList(drawLines []Line, eraseLine Line) []Line {
	var result []Line
	globalEraseLine := toGlobalLine(eraseLine)
	
	// For each drawing line, check if it should be erased
	for _, drawLine := range drawLines {
		globalDrawLine := toGlobalLine(drawLine)
		
		// Check if the entire line is within eraser width
		wholeLineWithinEraser := true
		
		// Skip empty lines
		if len(globalDrawLine.Points) < 2 {
			continue
		}
		
		// Calculate the thickness boundary
		totalThickness := float64(drawLine.Thickness+eraseLine.Thickness) / 2
		
		// Check each point to see if any are outside the eraser
		for _, point := range globalDrawLine.Points {
			minDistanceToEraserLine := math.MaxFloat64
			
			// Check distance to each segment of the eraser line
			for i := 1; i < len(globalEraseLine.Points); i++ {
				q1 := globalEraseLine.Points[i-1]
				q2 := globalEraseLine.Points[i]
				
				distance := distanceFromPointToLineSegment(point, q1, q2)
				if distance < minDistanceToEraserLine {
					minDistanceToEraserLine = distance
				}
			}
			
			// If any point is outside the eraser width, the whole line is not within eraser
			if minDistanceToEraserLine > totalThickness {
				wholeLineWithinEraser = false
				break
			}
		}
		
		// If the entire line is within the eraser width, skip it (it's erased)
		if wholeLineWithinEraser {
			continue
		}
		
		// Process the line normally to handle intersections
		newGlobalLines := eraseSegment(globalDrawLine, globalEraseLine)
		for _, newGlobalLine := range newGlobalLines {
			if len(newGlobalLine.Points) > 0 {
				newLocalLine := toLocalLine(newGlobalLine)
				result = append(result, newLocalLine)
			}
		}
	}
	return result
}

// eraseSegment takes a draw line and an erase line, and returns an array of lines
// representing the draw line with segments erased where the erase line intersects
// or where segments are entirely within the eraser's path
func eraseSegment(drawLine Line, eraseLine Line) []Line {
	// If lines don't have at least 2 points, return original line
	if len(drawLine.Points) < 2 || len(eraseLine.Points) < 2 {
		return []Line{drawLine}
	}

	var result []Line
	var currentSegment []Point
	currentSegment = append(currentSegment, drawLine.Points[0])

	// Process each segment of the draw line
	for i := 1; i < len(drawLine.Points); i++ {
		p1 := drawLine.Points[i-1]
		p2 := drawLine.Points[i]

		// Calculate the total thickness to use for erasing
		totalThickness := float64(drawLine.Thickness+eraseLine.Thickness) / 2
		
		// First check if this entire segment is within the eraser's path
		segmentErased := false
		
		// Check if both endpoints are within eraser's path for any eraser segment
		for j := 1; j < len(eraseLine.Points); j++ {
			q1 := eraseLine.Points[j-1]
			q2 := eraseLine.Points[j]
			
			// Check distance from both points to the eraser line segment
			p1Distance := distanceFromPointToLineSegment(p1, q1, q2)
			p2Distance := distanceFromPointToLineSegment(p2, q1, q2)
			
			// If both points are within the eraser's thickness, skip this entire segment
			if p1Distance <= totalThickness && p2Distance <= totalThickness {
				// End the current segment without adding this line
				if len(currentSegment) > 1 {
					result = append(result, Line{
						Points:    currentSegment,
						Thickness: drawLine.Thickness,
						Color:     drawLine.Color,
					})
				}
				
				// Start a new segment for the next iteration
				currentSegment = []Point{}
				segmentErased = true
				break
			}
		}
		
		// If segment was entirely erased, continue to the next segment
		if segmentErased {
			// Start with the next point for the next segment
			if i+1 < len(drawLine.Points) {
				currentSegment = []Point{drawLine.Points[i]}
			}
			continue
		}

		// Check intersection with each segment of erase line
		for j := 1; j < len(eraseLine.Points); j++ {
			q1 := eraseLine.Points[j-1]
			q2 := eraseLine.Points[j]

			intersects, intersectPoint := lineIntersects(p1, p2, q1, q2)
			if intersects && intersectPoint != nil {
				// Calculate points before and after intersection
				beforePoint, afterPoint := calculateErasePoints(*intersectPoint, p1, p2, totalThickness)

				// Add segment before intersection if it has length
				if len(currentSegment) > 0 && distanceBetweenPoints(currentSegment[len(currentSegment)-1], beforePoint) > 0.1 {
					currentSegment = append(currentSegment, beforePoint)
					result = append(result, Line{
						Points:    currentSegment,
						Thickness: drawLine.Thickness,
						Color:     drawLine.Color,
					})
				}

				// Start new segment from after intersection
				currentSegment = []Point{afterPoint}
				p1 = afterPoint // Update start point for next segment
			}
		}
		
		// Only add the point if we haven't erased the segment
		if !segmentErased {
			currentSegment = append(currentSegment, p2)
		}
	}

	// Add final segment if it has points
	if len(currentSegment) > 1 {
		result = append(result, Line{
			Points:    currentSegment,
			Thickness: drawLine.Thickness,
			Color:     drawLine.Color,
		})
	}

	return result
}

// calculateErasePoints calculates the points before and after an intersection
// based on the total thickness of both lines
func calculateErasePoints(intersectPoint, p1, p2 Point, totalThickness float64) (Point, Point) {
	// Calculate direction vector
	dx := p2.X - p1.X
	dy := p2.Y - p1.Y
	length := math.Sqrt(dx*dx + dy*dy)

	if length == 0 {
		return p1, p2
	}

	// Normalize direction vector
	dx /= length
	dy /= length

	// Calculate offset based on total thickness
	offsetX := dx * totalThickness
	offsetY := dy * totalThickness

	// Calculate points before and after intersection
	beforePoint := Point{
		X: intersectPoint.X - offsetX,
		Y: intersectPoint.Y - offsetY,
	}
	afterPoint := Point{
		X: intersectPoint.X + offsetX,
		Y: intersectPoint.Y + offsetY,
	}

	return beforePoint, afterPoint
}

// distanceBetweenPoints calculates the Euclidean distance between two points
func distanceBetweenPoints(p1, p2 Point) float64 {
	dx := p2.X - p1.X
	dy := p2.Y - p1.Y
	return math.Sqrt(dx*dx + dy*dy)
}

// distanceFromPointToLineSegment calculates the shortest distance from a point to a line segment
func distanceFromPointToLineSegment(p, lineStart, lineEnd Point) float64 {
	// Vector from line start to end
	lineVec := Point{X: lineEnd.X - lineStart.X, Y: lineEnd.Y - lineStart.Y}
	
	// Vector from line start to point
	pointVec := Point{X: p.X - lineStart.X, Y: p.Y - lineStart.Y}
	
	// Length of line segment
	lineLength := math.Sqrt(lineVec.X*lineVec.X + lineVec.Y*lineVec.Y)
	
	// If line segment has zero length, return distance to start point
	if lineLength < 1e-10 {
		return distanceBetweenPoints(p, lineStart)
	}
	
	// Normalize line vector
	lineVec.X /= lineLength
	lineVec.Y /= lineLength
	
	// Project point vector onto line vector to get the projection distance along the line
	projectionDistance := pointVec.X*lineVec.X + pointVec.Y*lineVec.Y
	
	var closestPoint Point
	
	// Check if projection falls outside the line segment
	if projectionDistance < 0 {
		// Closest point is line start
		closestPoint = lineStart
	} else if projectionDistance > lineLength {
		// Closest point is line end
		closestPoint = lineEnd
	} else {
		// Closest point is on the line segment
		closestPoint = Point{
			X: lineStart.X + projectionDistance*lineVec.X,
			Y: lineStart.Y + projectionDistance*lineVec.Y,
		}
	}
	
	// Calculate distance from point to closest point on line segment
	return distanceBetweenPoints(p, closestPoint)
}

// leftPad pads the input string `s` with the character `padChar` on the left
// until it reaches the specified `length`.
func leftPad(s string, length int, padChar rune) string {
	if len(s) >= length {
		return s
	}
	padding := make([]rune, length-len(s))
	for i := range padding {
		padding[i] = padChar
	}
	return string(padding) + s
}
