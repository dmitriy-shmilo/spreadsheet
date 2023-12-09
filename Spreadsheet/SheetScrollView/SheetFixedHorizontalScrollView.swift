//

import UIKit

class SheetFixedHorizontalScrollView: SheetScrollView {
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}

		guard sheet.allowedSelectionModes.contains(.column) else {
			return
		}

		let point = touch.location(in: self)
		guard let colIndex = findVisibleColumnIntersecting(
			offset: point.x)?.index else {
			return
		}
		
		if sheet.delegate?.sheet(sheet, shouldSelectColumnAt: colIndex) ?? true {
			sheet.setSelection(.columnSet(indices: .init(integer: colIndex)))
			sheet.scrollToSelection(selection, animated: true)
		}
	}

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

	override func isSelectionSupported(_ selection: SheetSelection) -> Bool {
		switch selection {
		case .columnSet(_), .columnRange(_, _):
			return true
		default:
			return false
		}
	}
}
