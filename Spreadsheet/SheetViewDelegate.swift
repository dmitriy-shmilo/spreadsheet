//

import UIKit

public protocol SheetViewDelegate: AnyObject {
	// MARK: - Interaction
	func sheet(_ sheet: SheetView, didTouchCellAt index: SheetIndex)
	func sheet(_ sheet: SheetView, didTouchFixedRowCellAt index: SheetIndex, in area: SheetViewArea)
	func sheet(_ sheet: SheetView, didTouchFixedColumnCellAt index: SheetIndex, in area: SheetViewArea)

	// MARK: - Selection
	func sheet(_ sheet: SheetView, shouldSelectCellAt index: SheetIndex) -> Bool
	func sheet(_ sheet: SheetView, shouldSelectColumnAt index: Int) -> Bool
	func sheet(_ sheet: SheetView, shouldSelectRowAt index: Int) -> Bool
	func sheet(_ sheet: SheetView, didChangeSelection to: SheetSelection, from: SheetSelection)

	// MARK: - Cell Editing
	func sheet(_ sheet: SheetView, didEndEditingCellAt index: SheetIndex, with editor: UIView)
}

public extension SheetViewDelegate {
	func sheet(_ sheet: SheetView, didTouchCellAt index: SheetIndex) {
		guard sheet.allowedSelectionModes.contains(.cell) else {
			return
		}

		if case .cell(let col, let row) = sheet.currentSelection,
		   row == index.row && col == index.col {
			sheet.editCellAt(index)
			return
		}

		sheet.setSelection(.cell(column: index.col, row: index.row))
		sheet.scrollToCurrentSelection(animated: true)
	}

	func sheet(_ sheet: SheetView, didTouchFixedRowCellAt index: SheetIndex, in area: SheetViewArea) {
		guard sheet.allowedSelectionModes.contains(.column) else {
			return
		}

		sheet.setSelection(.columnSet(indices: .init(integer: index.col)))
		sheet.scrollToCurrentSelection(animated: true)
	}

	func sheet(_ sheet: SheetView, didTouchFixedColumnCellAt index: SheetIndex, in area: SheetViewArea) {
		guard sheet.allowedSelectionModes.contains(.row) else {
			return
		}

		sheet.setSelection(.rowSet(indices: .init(integer: index.row)))
		sheet.scrollToCurrentSelection(animated: true)
	}

	func sheet(_ sheet: SheetView, shouldSelectCellAt index: SheetIndex) -> Bool {
		return true
	}

	func sheet(_ sheet: SheetView, shouldSelectColumnAt index: Int) -> Bool {
		return true
	}

	func sheet(_ sheet: SheetView, shouldSelectRowAt index: Int) -> Bool {
		return true
	}

	func sheet(_ sheet: SheetView, didChangeSelection to: SheetSelection, from: SheetSelection) {
		// no-op
	}

	func sheet(_ sheet: SheetView, shouldEditCellAt index: SheetIndex) -> Bool {
		return false
	}

	func sheet(_ sheet: SheetView, didEndEditingCellAt index: SheetIndex, with editor: UIView) {
		// no-op
	}
}
