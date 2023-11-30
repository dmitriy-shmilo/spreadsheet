//

import UIKit

class SpreadsheetScrollView: UIScrollView {
	private var maxQueue = 0

	let colCount = 10000
	let rowCount = 10000
	let colWidth = 100.0
	let rowHeight = 30.0

	var cellQueue = [UIView]()
	var reuseIndex = 0

	var visibleCells = [SpreadsheetIndex: UIView]()

	var visibleColCount = 0
	var visibleRowCount = 0
	var visibleLeftColumn = 0
	var visibleTopRow = 0

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()

	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	private func setup() {
		contentSize = .init(width: Double(colCount) * colWidth, height: Double(rowCount) * rowHeight)
	}

	private func createCell() -> UIView {
		let view = UILabel()
		view.layer.borderWidth = 1.0
		view.layer.borderColor = .init(gray: 0.3, alpha: 0.7)
		view.backgroundColor = .white
		view.textColor = .black
		view.text = "\(reuseIndex)"
		reuseIndex += 1
		return view
	}

	private func dequeueCell() -> UIView {
		let cell = cellQueue.popLast() ?? createCell()
		addSubview(cell)
		return cell
	}

	private func enqueueCell(_ cell: UIView) {
		cell.removeFromSuperview()
		if cellQueue.count < visibleCells.count {
			cellQueue.append(cell)
		}
	}

	private func makeIndex(_ col: Int, _ row: Int) -> SpreadsheetIndex {
		return .init(col: col, row: row, index: col + row * colCount)
	}

	private func trimQueue() {
		if cellQueue.count > visibleColCount * visibleRowCount {
			cellQueue.removeLast(cellQueue.count - visibleCells.count)
		}
	}

	override var contentOffset: CGPoint {
		didSet {
			visibleColCount = Int(ceil(frame.width / Double(colWidth))) + 2
			visibleRowCount = Int(ceil(frame.height / Double(rowHeight))) + 2

			let topLeft = contentOffset
			let bottomRight = CGPoint(x: contentOffset.x + frame.width,
									  y: contentOffset.y + frame.height)
			let top = max(0, Int(topLeft.y / rowHeight) - 1)
			let left = max(0, Int(topLeft.x / colWidth) - 1)
			let right = min(colCount, left + visibleColCount)
			let bottom = min(rowCount, top + visibleRowCount)
			for index in visibleCells.keys {
				if index.col < left || index.col > right
					|| index.row < top || index.row > bottom {
					if let cell = visibleCells.removeValue(forKey: index) {
						enqueueCell(cell)
					}
				}
			}

			trimQueue()

			for x in left..<right {
				for y in top..<bottom {
					let index = makeIndex(x, y)
					if visibleCells[index] == nil {
						let cell = dequeueCell()
						cell.frame = .init(
							x: Double(x) * colWidth,
							y: Double(y) * rowHeight,
							width: colWidth,
							height: rowHeight)
						visibleCells[index] = cell
					}
				}
			}
		}
	}
}
