//

import UIKit

// FIXME: There's a lot of shared properties and logic between this and the content scrollview.
class SheetFixedRowScrollView: UIScrollView {
	weak var sheet: SheetView!

	private var visibleCells = [SheetIndex: SheetViewCell]()
	private var leftColumn = 0
	private var rightColumn = 0
	private var topRow = 0
	private var bottomRow = 0

	override var contentOffset: CGPoint {
		didSet {
			guard let sheet = sheet else {
				return
			}

			let topLeft = contentOffset
			let bottomRight = CGPoint(x: contentOffset.x + frame.width,
									  y: contentOffset.y + frame.height)
			let cols = sheet.columns
			let rows = sheet.fixedTopRows

			let leftIndex = cols.firstIndex {
				$0.offset <= topLeft.x && $0.offset + $0.width >= topLeft.x
			} ?? 0
			let rightIndex = cols.firstIndex {
				$0.offset <= bottomRight.x && $0.offset + $0.width >= bottomRight.x
			} ?? sheet.columns.count - 1

			leftColumn = max(0, leftIndex - 1)
			rightColumn = min(cols.count, rightIndex + 1)
			topRow = 0
			bottomRow = sheet.fixedTopRows.count

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
							x: cols[x].offset,
							y: rows[y].offset,
							width: cols[x].width,
							height: rows[y].height)
						visibleCells[index] = cell
					}
				}
			}
		}
	}

	func refreshContentMeasurements() {
		guard let row = sheet.fixedTopRows.last,
			  let column = sheet.columns.last else {
			contentSize = .zero
			return
		}

		contentSize = .init(
			width: column.offset + column.width,
			height: row.offset + row.height)
	}
}
