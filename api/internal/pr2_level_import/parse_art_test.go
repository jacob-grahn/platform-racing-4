package pr2_level_import

import (
	"fmt"
	"math"
	"reflect"
	"testing"
)

func TestParseArt(t *testing.T) {
	artArr := []string{"d10155;10082;0;-7;0;-13"}
	layer := parseArt(artArr)

	expectedLines := []Line{{
		X: 10155,
		Y: 10082,
		Points: []Point{
			{X: 0, Y: -7},
			{X: 0, Y: -20},
		},
		Color:     "000000",
		Thickness: 1,
		Mode:      "draw",
	}}

	if !reflect.DeepEqual(layer.Lines, expectedLines) {
		t.Errorf("Expected %+v, got %+v", expectedLines, layer.Lines)
	}
}

func TestParseArtWithErase(t *testing.T) {
	// Create a simple test case: 
	// 1. A single horizontal line
	// 2. An eraser that cuts through the middle
	artArr := []string{
		"mdraw",         // Set draw mode
		"t2",            // Set thickness to 2
		"d100;100;200;0", // Draw horizontal line from (100,100) to (300,100)
		"merase",        // Set erase mode
		"t10",           // Set eraser thickness to 10
		"d200;80;0;40",  // Draw vertical erase line through middle from (200,80) to (200,120)
	}
	
	layer := parseArt(artArr)

	// We expect exactly two line segments after erasing
	if len(layer.Lines) != 2 {
		t.Errorf("Expected 2 line segments after erasing, got %d", len(layer.Lines))
		t.Logf("Lines: %+v", layer.Lines)
		return
	}

	// Sort lines by X coordinate to ensure consistent testing
	leftLine := layer.Lines[0]
	rightLine := layer.Lines[1]
	if leftLine.X > rightLine.X {
		leftLine, rightLine = rightLine, leftLine
	}

	// Verify left line is on the left side of the eraser
	if leftLine.X + leftLine.Points[len(leftLine.Points)-1].X > 195 {
		t.Errorf("Left line should end before X=195, got ending X=%v", 
			leftLine.X + leftLine.Points[len(leftLine.Points)-1].X)
	}

	// Verify right line is on the right side of the eraser
	if rightLine.X < 205 {
		t.Errorf("Right line should start after X=205, got X=%v", rightLine.X)
	}

	// Verify that both lines have the expected thickness
	if leftLine.Thickness != 2 || rightLine.Thickness != 2 {
		t.Errorf("Expected both lines to have thickness=2, got left=%d, right=%d", 
			leftLine.Thickness, rightLine.Thickness)
	}

	// Verify the eraser removed the middle portion (between X=195 and X=205)
	for _, line := range layer.Lines {
		for _, point := range line.Points {
			// Convert to global coordinates for easier checking
			globalX := line.X + point.X
			// Check that there are no points in the erased area
			if globalX > 195 && globalX < 205 {
				t.Errorf("Found point in erased area at (%v,%v) in line starting at (%v,%v)", 
					globalX, line.Y+point.Y, line.X, line.Y)
			}
		}
	}
}

func TestEraseEntireSegments(t *testing.T) {
	// Create a simpler test case for removing entire segments within eraser radius
	// Draw a square and erase through the middle with a wide eraser
	artArr := []string{
		"mdraw",       // Set draw mode
		"t2",          // Set thickness to 2
		"d100;100;100;0;0;100;-100;0", // Draw square: (100,100) → (+100,0) → (0,+100) → (-100,0)
		"merase",      // Set erase mode
		"t5",          // Set eraser thickness to 5 (we want narrow to test the fix)
		"d150;130;0;40", // Draw vertical eraser line through the middle of one side
	}
	
	layer := parseArt(artArr)
	
	// Log the results to understand what we're getting
	t.Logf("Number of segments after erasing: %d", len(layer.Lines))
	for i, line := range layer.Lines {
		globalPoints := make([]string, len(line.Points))
		for j, p := range line.Points {
			globalPoints[j] = fmt.Sprintf("(%.1f,%.1f)", line.X+p.X, line.Y+p.Y)
		}
		t.Logf("Segment %d: start(%.1f, %.1f), global points: %v", 
			i, line.X, line.Y, globalPoints)
	}

	// The issue is with the first approach - we're testing the wrong things
	// The problem is that line segments that don't directly intersect with the eraser line
	// but are entirely within its thickness are not being removed.
	
	// Let's manually check one specific segment - the top horizontal line of the square
	// from (100,100)+(100,0) to (200,100)+(0,100) should be split by the eraser at (150,y)
	horizontalSegmentFound := false
	
	for _, line := range layer.Lines {
		for i := 0; i < len(line.Points); i++ {
			p := line.Points[i]
			globalX := line.X + p.X
			globalY := line.Y + p.Y
			
			// Check for the top horizontal segment at y=200
			if math.Abs(globalY - 200) < 1.0 {
				// Found a point on the top horizontal - check if it crosses the eraser
				if globalX > 145 && globalX < 155 {
					t.Errorf("Found point at (%.1f, %.1f) in eraser path - segment should be split", 
						globalX, globalY)
				}
				horizontalSegmentFound = true
			}
		}
	}
	
	// There should be a horizontal segment
	if !horizontalSegmentFound {
		t.Errorf("Expected to find horizontal segment at y=200, but none found")
	}
	
	// Debug the eraser implementation by using a simple test case
	// We'll draw a single horizontal line and erase it with a vertical line
	artArr2 := []string{
		"mdraw",       // Set draw mode
		"t2",          // Set thickness to 2
		"d100;150;100;0", // Draw horizontal line from (100,150) to (200,150)
		"merase",      // Set erase mode
		"t20",         // Set eraser thickness to 20
		"d150;140;0;20", // Draw vertical eraser through the middle of the line
	}
	
	layer2 := parseArt(artArr2)
	t.Logf("Simple test - line with eraser through the middle:")
	t.Logf("Number of segments after erasing: %d", len(layer2.Lines))
	
	for i, line := range layer2.Lines {
		globalPoints := make([]string, len(line.Points))
		for j, p := range line.Points {
			globalPoints[j] = fmt.Sprintf("(%.1f,%.1f)", line.X+p.X, line.Y+p.Y)
		}
		t.Logf("Segment %d: start(%.1f, %.1f), global points: %v", 
			i, line.X, line.Y, globalPoints)
	}
	
	// Should have split the line into two segments
	if len(layer2.Lines) != 2 {
		t.Errorf("Expected line to be split into 2 segments, but got %d segments", len(layer2.Lines))
	}
	
	// Try one more test case with a small shape fully inside eraser
	artArr3 := []string{
		"mdraw",       // Set draw mode
		"t2",          // Set thickness to 2
		"d150;150;10;0;0;10;-10;0;0;-10", // Draw tiny square centered at (150,150)
		"merase",      // Set erase mode
		"t40",         // Set eraser thickness to 40
		"d150;150;0;0", // Draw point eraser (should cover the whole square)
	}
	
	// Add debug output to understand what's happening
	t.Logf("\nLine definitions in eraseWithinRadius test case:")
	for i, line := range artArr3 {
		t.Logf("Line %d: %s", i, line)
	}
	
	layer3 := parseArt(artArr3)
	
	t.Logf("\nFinal test - tiny shape with large eraser:")
	t.Logf("Number of segments after erasing: %d", len(layer3.Lines))
	
	for i, line := range layer3.Lines {
		globalPoints := make([]string, len(line.Points))
		for j, p := range line.Points {
			globalPoints[j] = fmt.Sprintf("(%.1f,%.1f)", line.X+p.X, line.Y+p.Y)
		}
		t.Logf("Segment %d: start(%.1f, %.1f), global points: %v", 
			i, line.X, line.Y, globalPoints)
	}
	
	// This tiny shape should be completely erased
	if len(layer3.Lines) > 0 {
		t.Errorf("Expected all segments to be erased, but found %d segments", len(layer3.Lines))
	}
}

func TestEraseLineSegments(t *testing.T) {
	// Test erasing line segments that are entirely within the eraser's width
	// Draw a horizontal line and use a thick vertical eraser that fully contains a segment
	artArr := []string{
		"mdraw",         // Set draw mode
		"t2",            // Set thickness to 2
		"d100;100;200;0", // Draw horizontal line from (100,100) to (300,100)
		"merase",        // Set erase mode
		"t60",           // Set eraser thickness to 60 (wide enough to remove an entire segment)
		"d200;80;0;40",  // Draw vertical eraser through the middle
	}
	
	layer := parseArt(artArr)
	
	// Log the results
	t.Logf("Number of segments after erasing: %d", len(layer.Lines))
	for i, line := range layer.Lines {
		t.Logf("Segment %d: start=(%v,%v), points=%+v", 
			i, line.X, line.Y, line.Points)
	}

	// Should have exactly 2 segments: one on the left and one on the right
	if len(layer.Lines) != 2 {
		t.Errorf("Expected 2 line segments after erasing, got %d", len(layer.Lines))
		return
	}
	
	// Define the eraser boundaries
	eraserLeftBound := 170.0  // center (200) - half width (30)
	eraserRightBound := 230.0 // center (200) + half width (30)
	
	// Check that no points exist within the eraser's width
	for _, line := range layer.Lines {
		for _, point := range line.Points {
			globalX := line.X + point.X
			if globalX > eraserLeftBound && globalX < eraserRightBound {
				t.Errorf("Found point at x=%.1f within eraser width - should be erased", globalX)
			}
		}
	}
	
	// Test a more complex case - segments parallel to eraser but within its width
	artArr2 := []string{
		"mdraw",         // Set draw mode
		"t2",            // Set thickness to 2
		"d170;80;0;40;60;0", // Draw vertical line near eraser from (170,80) to (170,120) to (230,120)
		"merase",        // Set erase mode
		"t40",           // Set eraser thickness to 40
		"d200;80;0;40",  // Draw vertical eraser through the middle
	}
	
	layer2 := parseArt(artArr2)
	
	// Log the results
	t.Logf("\nSecond test case - parallel segments:")
	t.Logf("Number of segments after erasing: %d", len(layer2.Lines))
	for i, line := range layer2.Lines {
		globalPoints := make([]string, 0)
		globalPoints = append(globalPoints, fmt.Sprintf("(%.1f,%.1f)", line.X, line.Y))
		for _, p := range line.Points {
			globalPoints = append(globalPoints, fmt.Sprintf("(%.1f,%.1f)", line.X+p.X, line.Y+p.Y))
		}
		t.Logf("Segment %d: global points: %v", i, globalPoints)
	}
	
	// The vertical segment should be completely erased if it's within the eraser's width
	// We should only have one segment remaining (the horizontal one on the right)
	if len(layer2.Lines) > 1 {
		// Check if we have a vertical segment within the eraser bounds
		for _, line := range layer2.Lines {
			for _, point := range line.Points {
				globalX := line.X + point.X
				if globalX > 180 && globalX < 220 {
					t.Errorf("Found vertical segment within eraser width - should be completely erased")
				}
			}
		}
	}
}

func TestEraseSegmentList(t *testing.T) {
	drawLines := []Line{
		{
			X: 0,
			Y: 0,
			Points: []Point{
				{X: 100, Y: 0},
			},
			Thickness: 10,
		},
		{
			X: 200,
			Y: 200,
			Points: []Point{
				{X: 100, Y: 100},
			},
			Thickness: 10,
		},
	}

	eraseLine := Line{
		X: 50,
		Y: -100,
		Points: []Point{
			{X: 0, Y: 200},
		},
		Thickness: 20,
	}

	expected := []Line{
		{
			X: 0,
			Y: 0,
			Points: []Point{
				{X: 35, Y: 0},
			},
			Thickness: 10,
		},
		{
			X: 65,
			Y: 0,
			Points: []Point{
				{X: 35, Y: 0},
			},
			Thickness: 10,
		},
		{
			X: 200,
			Y: 200,
			Points: []Point{
				{X: 100, Y: 100},
			},
			Thickness: 10,
		},
	}

	result := eraseSegmentList(drawLines, eraseLine)

	if !reflect.DeepEqual(result, expected) {
		t.Errorf("eraseSegmentList() = %v, want %v", result, expected)
	}
}

// TestEraseSegment tests the eraseSegment function.
func TestEraseSegment(t *testing.T) {
	drawLine := Line{
		Points: []Point{
			{X: 0, Y: 0},
			{X: 100, Y: 0},
		},
		Thickness: 10,
		Color:     "123456",
	}

	eraseLine := Line{
		Points: []Point{
			{X: 50, Y: -100},
			{X: 50, Y: 100},
		},
		Thickness: 20,
	}

	expected := []Line{
		{
			Points: []Point{
				{X: 0, Y: 0},
				{X: 35, Y: 0},
			},
			Thickness: 10,
			Color:     "123456",
		},
		{
			Points: []Point{
				{X: 65, Y: 0},
				{X: 100, Y: 0},
			},
			Thickness: 10,
			Color:     "123456",
		},
	}

	result := eraseSegment(drawLine, eraseLine)

	if !reflect.DeepEqual(result, expected) {
		t.Errorf("eraseSegment() = %v, want %v", result, expected)
	}
}

func TestToGlobalLine(t *testing.T) {
	localLine := Line{
		X: 100,
		Y: -100,
		Points: []Point{
			{X: 100, Y: 0},
			{X: 200, Y: 200},
		},
		Thickness: 7,
		Color:     "FFFFFF",
	}

	expectedGlobalLine := Line{
		X: 0,
		Y: 0,
		Points: []Point{
			{X: 100, Y: -100},
			{X: 200, Y: -100},
			{X: 300, Y: 100},
		},
		Thickness: 7,
		Color:     "FFFFFF",
	}

	result := toGlobalLine(localLine)

	if !reflect.DeepEqual(result, expectedGlobalLine) {
		t.Errorf("toGlobalLine() = %v, want %v", result, expectedGlobalLine)
	}
}

func TestToLocalLine(t *testing.T) {
	globalLine := Line{
		X: 0,
		Y: 0,
		Points: []Point{
			{X: 100, Y: -100},
			{X: 200, Y: -100},
			{X: 300, Y: 100},
		},
		Thickness: 7,
		Color:     "FFFFFF",
	}

	expectedLocalLine := Line{
		X: 100,
		Y: -100,
		Points: []Point{
			{X: 100, Y: 0},
			{X: 200, Y: 200},
		},
		Thickness: 7,
		Color:     "FFFFFF",
	}

	result := toLocalLine(globalLine)

	if !reflect.DeepEqual(result, expectedLocalLine) {
		t.Errorf("toLocalLine() = %v, want %v", result, expectedLocalLine)
	}
}

func TestLineIntersects(t *testing.T) {
	tests := []struct {
		p1, p2, q1, q2 Point
		expected       bool
		intersection   *Point
	}{
		{
			p1:           Point{X: 0, Y: 0},
			p2:           Point{X: 4, Y: 4},
			q1:           Point{X: 0, Y: 4},
			q2:           Point{X: 4, Y: 0},
			expected:     true,
			intersection: &Point{X: 2, Y: 2},
		},
		{
			p1:           Point{X: 0, Y: 0},
			p2:           Point{X: 4, Y: 4},
			q1:           Point{X: 5, Y: 5},
			q2:           Point{X: 7, Y: 7},
			expected:     false,
			intersection: nil,
		},
		//{
		//	p1:           Point{X: 0, Y: 0},
		//	p2:           Point{X: 4, Y: 4},
		//	q1:           Point{X: 2, Y: 2},
		//	q2:           Point{X: 6, Y: 6},
		//	expected:     true,
		//	intersection: &Point{X: 2, Y: 2}, // Collinear overlap
		//},
		{
			p1:           Point{X: 0, Y: 0},
			p2:           Point{X: 4, Y: 0},
			q1:           Point{X: 2, Y: -1},
			q2:           Point{X: 2, Y: 1},
			expected:     true,
			intersection: &Point{X: 2, Y: 0},
		},
		{
			p1:           Point{X: 0, Y: 0},
			p2:           Point{X: 4, Y: 0},
			q1:           Point{X: 5, Y: -1},
			q2:           Point{X: 5, Y: 1},
			expected:     false,
			intersection: nil,
		},
	}

	for _, test := range tests {
		actual, point := lineIntersects(test.p1, test.p2, test.q1, test.q2)
		if actual != test.expected {
			t.Errorf("Expected intersection %v, got %v for lines (%v, %v) and (%v, %v)",
				test.expected, actual, test.p1, test.p2, test.q1, test.q2)
		}
		if test.intersection != nil {
			if point == nil || *point != *test.intersection {
				t.Errorf("Expected intersection point %v, got %v for lines (%v, %v) and (%v, %v)",
					*test.intersection, point, test.p1, test.p2, test.q1, test.q2)
			}
		} else if point != nil {
			t.Errorf("Expected no intersection point, but got %v for lines (%v, %v) and (%v, %v)",
				point, test.p1, test.p2, test.q1, test.q2)
		}
	}
}
