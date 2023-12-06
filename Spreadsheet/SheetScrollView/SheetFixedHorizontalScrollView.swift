//

import UIKit

class SheetFixedHorizontalScrollView: SheetScrollView {

	override func determineRange(
		from topLeft: CGPoint,
		to bottomRight: CGPoint)
	-> SheetCellRange {
		let leftIndex = findColumnIntersecting(offset: topLeft.x)?.index ?? 0
		let rightIndex = findColumnIntersecting(offset: bottomRight.x)?.index ?? columns.count - 1
		return SheetCellRange(
			leftColumn: max(0, leftIndex - 1),
			rightColumn: min(columns.count, rightIndex + 1),
			topRow: 0,
			bottomRow: rows.count)
	}
}
