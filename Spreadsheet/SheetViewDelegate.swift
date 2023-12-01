//

import Foundation

public protocol SheetViewDelegate: AnyObject {
	func sheet(_ sheet: SheetView, shouldSelectCellAt index: SheetIndex) -> Bool
	func sheet(_ sheet: SheetView, didChangeSelection to: SheetSelection, from: SheetSelection)
}

extension SheetViewDelegate {
	func sheet(_ sheet: SheetView, shouldSelectCellAt index: SheetIndex) -> Bool {
		return true
	}

	func sheet(_ sheet: SheetView, didChangeSelection to: SheetSelection, from: SheetSelection) {
		// no-op
	}
}
