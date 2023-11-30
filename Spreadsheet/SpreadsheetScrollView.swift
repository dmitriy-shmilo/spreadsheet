//

import UIKit

class SpreadsheetScrollView: UIScrollView {
	private var maxQueue = 0

	var colCount = 0
	var rowCount = 0
	var estColWidth: CGFloat = 1.0
	var estRowHeight: CGFloat = 1.0

	var reuseIndex = 0

	var visibleCells = [SpreadsheetIndex: UIView]()

	var visibleColCount = 0
	var visibleRowCount = 0
	var visibleLeftColumn = 0
	var visibleTopRow = 0

	weak var sheet: SpreadsheetView!

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override var contentOffset: CGPoint {
		didSet {
			visibleColCount = Int(ceil(frame.width / Double(estColWidth))) + 2
			visibleRowCount = Int(ceil(frame.height / Double(estRowHeight))) + 2

			let topLeft = contentOffset
			let bottomRight = CGPoint(x: contentOffset.x + frame.width,
									  y: contentOffset.y + frame.height)
			let top = max(0, Int(topLeft.y / estRowHeight) - 1)
			let left = max(0, Int(topLeft.x / estColWidth) - 1)
			let right = min(colCount, left + visibleColCount)
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
							x: CGFloat(x) * estColWidth,
							y: CGFloat(y) * estRowHeight,
							width: estColWidth,
							height: estRowHeight)
						visibleCells[index] = cell
					}
				}
			}
		}
	}

	func refreshContentMeasurements() {
		contentSize = .init(
			width: CGFloat(colCount) * estColWidth,
			height: CGFloat(rowCount) * estRowHeight)
	}

	private func makeIndex(_ x: Int, _ y: Int) -> SpreadsheetIndex {
		return .init(col: x, row: y, index: x + y * colCount)
	}
}
