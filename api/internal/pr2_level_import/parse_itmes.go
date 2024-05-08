package pr2_level_import

import (
	"strings"
)

func parseItems(str string) []string {
	if str == "" {
		return nil
	}

	const hashLen = 32
	items := strings.Split(str, "`")

	if len(items) > 0 {
		lastItem := items[len(items)-1]
		if len(lastItem) > hashLen {
			items[len(items)-1] = lastItem[:len(lastItem)-hashLen]
		}
	}

	return items
}
