//

import UIKit

class SheetScrollView: UIScrollView {
	private var maxQueue = 0

	var rowCount = 0
	var estRowHeight: CGFloat = 1.0
	var visibleCells = [SheetIndex: SheetViewCell]()
	var visibleRowCount = 0

	weak var sheet: SheetView!

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override var contentOffset: CGPoint {
		didSet {
			guard let sheet = sheet else {
				return
			}

			let topLeft = contentOffset
			let bottomRight = CGPoint(x: contentOffset.x + frame.width,
									  y: contentOffset.y + frame.height)
			let cols = sheet.columns

			// TODO: For a relatively small number of columns the following
			// linear search will perform OK. But for a large number of
			// columns we should leverage the fact that sheet.columns
			// is sorted by offset, and use binary search.

			// find the leftmost and rightmost visible column indicies
			let leftIndex = cols.firstIndex {
				$0.offset <= topLeft.x && $0.offset + $0.width >= topLeft.x
			} ?? 0
			let rightIndex = cols.firstIndex {
				$0.offset <= bottomRight.x && $0.offset + $0.width >= bottomRight.x
			} ?? sheet.columns.count - 1

			let left = max(0, leftIndex - 1)
			let right = min(sheet.columns.count - 1, rightIndex + 1)

			visibleRowCount = Int(ceil(frame.height / Double(estRowHeight))) + 2
			let top = max(0, Int(topLeft.y / estRowHeight) - 1)
			let bottom = min(rowCount, top + visibleRowCount)

			for index in visibleCells.keys {
				if index.col < left || index.col > right
					|| index.row < top || index.row > bottom {
					if let cell = visibleCells.removeValue(forKey: index) {
						sheet.freeCell(cell)
					}
				}
			}

			for x in left..<right {
				for y in top..<bottom {
					let index = makeIndex(x, y)
					if visibleCells[index] == nil {
						let cell = sheet.cellFor(index)
						addSubview(cell)
						cell.frame = .init(
							x: cols[x].offset,
							y: CGFloat(y) * estRowHeight,
							width: cols[x].width,
							height: estRowHeight)
						visibleCells[index] = cell
					}
				}
			}
		}
	}

	func refreshContentMeasurements() {
		// TODO: cache the total width
		contentSize = .init(
			width: sheet.columns.map { $0.width }.reduce(0, +),
			height: CGFloat(rowCount) * estRowHeight)
	}

	private func makeIndex(_ x: Int, _ y: Int) -> SheetIndex {
		return .init(col: x, row: y, index: x + y * sheet.columns.count)
	}
}
