//

import UIKit

class SheetFixedHorizontalScrollView: SheetScrollView {

	override var contentOffset: CGPoint {
		didSet {
			guard let sheet = sheet else {
				return
			}

			let topLeft = contentOffset
			let bottomRight = CGPoint(x: contentOffset.x + frame.width,
									  y: contentOffset.y + frame.height)

			let leftIndex = findColumnIntersecting(offset: topLeft.x)?.index ?? 0
			let rightIndex = findColumnIntersecting(offset: bottomRight.x)?.index ?? columns.count - 1

			leftColumn = max(0, leftIndex - 1)
			rightColumn = min(columns.count, rightIndex + 1)
			topRow = 0
			bottomRow = rows.count

			for index in visibleCells.keys {
				if index.col < leftColumn || index.col > rightColumn
					|| index.row < topRow || index.row > bottomRow {
					if let cell = visibleCells.removeValue(forKey: index) {
						sheet.releaseCell(cell)
					}
				}
			}

			for x in leftColumn..<rightColumn {
				for y in topRow..<bottomRow {
					let index = sheet.makeIndex(x, y)
					if visibleCells[index] == nil {
						let cell = sheet.cellFor(index, in: .fixedTop)
						addSubview(cell)
						cell.frame = .init(
							x: columns[x].offset,
							y: rows[y].offset,
							width: columns[x].width,
							height: rows[y].height)
						visibleCells[index] = cell
					}
				}
			}
		}
	}
}
