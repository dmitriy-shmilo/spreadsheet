//

import UIKit

class SheetFixedHorizontalScrollView: SheetScrollView {

	override var contentOffset: CGPoint {
		didSet {
			let topLeft = contentOffset
			let bottomRight = CGPoint(x: contentOffset.x + frame.width,
									  y: contentOffset.y + frame.height)

			let leftIndex = findColumnIntersecting(offset: topLeft.x)?.index ?? 0
			let rightIndex = findColumnIntersecting(offset: bottomRight.x)?.index ?? columns.count - 1
			let range = SheetCellRange(
				leftColumn: max(0, leftIndex - 1),
				rightColumn: min(columns.count, rightIndex + 1),
				topRow: 0,
				bottomRow: rows.count)

			guard visibleRange != range else {
				return
			}
			
			visibleRange = range
			releaseCells(in: visibleRange)
			addCells(in: visibleRange)
			
		}
	}
}
