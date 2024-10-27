package pr2_level_import

import (
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

// TestEraseSegment tests the eraseSegment function.
func TestEraseSegment(t *testing.T) {
	drawLine := Line{
		Points: []Point{
			{X: 0, Y: 0},
			{X: 100, Y: 0},
		},
		Thickness: 10,
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
		},
		{
			Points: []Point{
				{X: 65, Y: 0},
				{X: 100, Y: 0},
			},
			Thickness: 10,
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
