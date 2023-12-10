//

import UIKit

class SheetFixedVerticalScrollView: SheetScrollView {

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}

		let point = touch.location(in: self)
		guard let colIndex = findVisibleColumnIntersecting(
			offset: point.x)?.index else {
			return
		}

		guard let rowIndex = findVisibleRowIntersecting(offset: point.y)?.index else {
			return
		}
		sheet.delegate?.sheet(
			sheet,
			didTouchFixedColumnCellAt: sheet.makeIndex(colIndex, rowIndex),
			in: area)
	}

	override func determineRange(
		from topLeft: CGPoint,
		to bottomRight: CGPoint)
	-> SheetCellRange {
		let topIndex = findRowIntersecting(offset: topLeft.y)?.index ?? 0
		let bottomIndex = findRowIntersecting(offset: bottomRight.y)?.index ?? rows.count - 1
		return SheetCellRange(
			leftColumn: 0,
			rightColumn: columns.count,
			topRow: max(0, topIndex - 1),
			bottomRow: min(rows.count, bottomIndex + 1))
	}

	override func isSelectionSupported(_ selection: SheetSelection) -> Bool {
		switch selection {
		case .rowSet(_), .rowRange(_, _):
			return true
		default:
			return false
		}
	}
}
