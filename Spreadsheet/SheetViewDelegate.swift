//

import UIKit

/// Assign an implementation of this protocol to ``SheetView/delegate`` in order to
/// receive various callbacks and influence the behavior of a ``SheetView``.
public protocol SheetViewDelegate: AnyObject {
	// MARK: - Interaction
	/// Called when a cell in ``SheetViewArea/content`` is tapped or clicked.
	/// The default implementation will mark the cell as selected, clearing any previous selections.
	/// If a selected cell is tapped once more, an editing attempt will be made.
	/// If the ``SheetView/allowedSelectionModes`` doesn't contain ``SheetViewSelectionMode/cell``,
	/// the default implementation doesn't do anything.
	func sheet(_ sheet: SheetView, didTouchCellAt index: SheetIndex)

	/// Called when a cell in ``SheetViewArea/fixedTop`` is tapped or clicked.
	/// The default implementation will mark the corresponding column as selected, clearing any previous selections.
	/// If the ``SheetView/allowedSelectionModes`` doesn't contain ``SheetViewSelectionMode/column``,
	/// the default implementation doesn't do anything.
	///
	/// - Parameter index: specifies an index within the given area, independent of the content.
	/// Its ``SheetIndex/col`` will correspond to a zero-based index of a column where the fixed cell resiedes.
	/// Its ``SheetIndex/row`` will be a value from zero to whatever ``SheetView/dataSource`` returns in
	/// ``SheetViewDataSource/sheetNumberOfFixedRows(_:in:)-40oxz``.
	func sheet(_ sheet: SheetView, didTouchFixedRowCellAt index: SheetIndex, in area: SheetViewArea)

	/// Called when a cell in ``SheetViewArea/fixedLeft`` is tapped or clicked.
	/// The default implementation will mark the corresponding row as selected, clearing any previous selections.
	/// If the ``SheetView/allowedSelectionModes`` doesn't contain ``SheetViewSelectionMode/column``,
	/// the default implementation doesn't do anything.
	/// - Parameter index: specifies an index within the given area, independent of the content.
	/// Its ``SheetIndex/col`` will be a value from zero to whatever ``SheetView/dataSource`` returns in
	/// ``SheetViewDataSource/sheetNumberOfFixedColumns(_:in:)-25dwe``.
	/// Its ``SheetIndex/row`` will correspond to a zero-based index of a row where the fixed cell resiedes.
	func sheet(_ sheet: SheetView, didTouchFixedColumnCellAt index: SheetIndex, in area: SheetViewArea)

	// MARK: - Selection
	/// Called when a ``SheetView/currentSelection`` is changed, usually via ``SheetView/setSelection(_:)``
	/// method. The default implementation doesn't do anything.
	///
	/// - Parameter to: new selection value.
	/// - Parameter from: previous selection value.
	func sheet(_ sheet: SheetView, didChangeSelection to: SheetSelection, from: SheetSelection)

	// MARK: - Cell Editing
	/// Called when editing action is finished, usually via a ``SheetView/endEditCell()`` call. The default
	/// implementation doesn't do anything, the editing results are discarded. Override this callback in order to persist the editing
	/// results.
	///
	/// - Parameter index: A cell index within the ``SheetViewArea/content`` area, for which the editor view
	/// was spawned.
	/// - Parameter editor: An editor view, which was created with
	///  ``SheetViewDataSource/sheet(_:editorCellFor:)-50o4m``. Use this view to retrieve the new data
	///  and persist it if necessary. Reload the affected cell in order to display the new data.
	func sheet(_ sheet: SheetView, didEndEditingCellAt index: SheetIndex, with editor: UIView)
}

// MARK: - Default Implementation
public extension SheetViewDelegate {
	// MARK: - Interaction
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

	// MARK: - Selection
	func sheet(_ sheet: SheetView, didChangeSelection to: SheetSelection, from: SheetSelection) {
		// no-op
	}

	// MARK: - Cell Editing
	func sheet(_ sheet: SheetView, didEndEditingCellAt index: SheetIndex, with editor: UIView) {
		// no-op
	}
}
