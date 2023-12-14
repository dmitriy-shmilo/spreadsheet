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

		if case .cellSet(let indices) = sheet.currentSelection,
		   indices.contains(index) {
			sheet.setSelection(.singleCell(with: index))
			sheet.editCellAt(index)
			return
		}

		sheet.setSelection(.singleCell(with: index))
		sheet.scrollToCurrentSelection(animated: true)
	}

	func sheet(_ sheet: SheetView, didTouchFixedRowCellAt index: SheetIndex, in area: SheetViewArea) {
		guard sheet.allowedSelectionModes.contains(.column) else {
			return
		}

		sheet.setSelection(.singleColumn(with: index.col))
		sheet.scrollToCurrentSelection(animated: true)
	}

	func sheet(_ sheet: SheetView, didTouchFixedColumnCellAt index: SheetIndex, in area: SheetViewArea) {
		guard sheet.allowedSelectionModes.contains(.row) else {
			return
		}

		sheet.setSelection(.singleRow(with: index.row))
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
