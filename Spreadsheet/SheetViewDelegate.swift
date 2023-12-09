//

import UIKit

public protocol SheetViewDelegate: AnyObject {
	// MARK: - Selection
	func sheet(_ sheet: SheetView, shouldSelectCellAt index: SheetIndex) -> Bool
	func sheet(_ sheet: SheetView, shouldSelectColumnAt index: Int) -> Bool
	func sheet(_ sheet: SheetView, shouldSelectRowAt index: Int) -> Bool
	func sheet(_ sheet: SheetView, didChangeSelection to: SheetSelection, from: SheetSelection)

	// MARK: - Cell Editing
	func sheet(_ sheet: SheetView, shouldEditCellAt index: SheetIndex) -> Bool
	func sheet(_ sheet: SheetView, didEndEditingCellAt index: SheetIndex, with editor: UIView)
}

public extension SheetViewDelegate {
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
