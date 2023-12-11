//

import Foundation

extension Array {
	func binarySearch(_ comparator: (Element) -> ComparisonResult) -> Element? {
		var lowerIndex = 0
		var upperIndex = self.count - 1

		while (lowerIndex <= upperIndex) {
			let currentIndex = (lowerIndex + upperIndex) / 2
			let comparison = comparator(self[currentIndex])
			switch comparison {
			case .orderedSame:
				return self[currentIndex]
			case .orderedAscending:
				upperIndex = currentIndex - 1
			case .orderedDescending:
				lowerIndex = currentIndex + 1
			}
		}
		return nil
	}
}
