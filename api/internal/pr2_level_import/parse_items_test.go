package pr2_level_import

import (
	"reflect"
	"testing"
)

func TestParseItems(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected []string
	}{
		{
			name:     "Parse items normally",
			input:    "Laser Gun`Mine`Lightning",
			expected: []string{"Laser Gun", "Mine", "Lightning"},
		},
		{
			name:     "Filter out a hash if it's there",
			input:    "Mine`Lightningaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
			expected: []string{"Mine", "Lightning"},
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			result := parseItems(test.input)
			if !reflect.DeepEqual(result, test.expected) {
				t.Errorf("Test %s failed: expected %v, got %v", test.name, test.expected, result)
			}
		})
	}
}
