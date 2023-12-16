//

import UIKit

/// Assign an implementation of this protocol to ``SheetView/dataSource`` in order to
/// provide values, necessary to display a spreadsheet table. SheetView without a data source will
/// not display any data.
public protocol SheetViewDataSource: AnyObject {
	// MARK: - View Production
	/// Implement this method and return an appropriate ``SheetViewCell`` or its subclass. Returned view will
	/// be placed in the content area of the sheet view. Make sure to populate necessary cell properties in this method.
	/// >Resulting cell will be sized in accordance to its corresponding column width and row height.
	///
	/// > For better performance utilize ``SheetView/register(_:forCellReuseIdentifier:)`` and retrieve
	/// > new cells with ``SheetView/dequeueReusableCell(withIdentifier:)``.
	func sheet(_ sheet: SheetView, cellFor index: SheetIndex) -> SheetViewCell

	/// A view returned from this method will be used as an editor view when ``SheetView/editCellAt(_:)`` is called,
	/// or cell editing is started by any other means. The same editor instance will be passed to
	/// ``SheetViewDelegate/sheet(_:didEndEditingCellAt:with:)-2sxsz``, use it to deliver the edited value.
	///
	/// > Resulting editor view will have the same size as its corresponding cell, however this might change in the future.
	///
	/// > Default implementation returns `nil`, which will result in an empty view displayed,
	/// however this might change in the future.
	/// > Empty view display is almost never the desired behavior. So make sure to override this method if the cell
	/// > editing is going to be supported.
	func sheet(_ sheet: SheetView, editorCellFor index: SheetIndex) -> UIView?

	/// Implement this method and return an appropriate ``SheetViewCell`` or its subclass. Returned view will
	/// be placed in the fixed row `area` at a given index. Make sure to populate the necessary cell properties in this method.
	///
	/// - Parameter index: will have its `row` value set to the fixed row index.
	///
	/// > Resulting cell will be sized in accordance to its corresponding column width and fixed row height.
	///
	/// > For better performance utilize ``SheetView/register(_:forCellReuseIdentifier:)`` and retrieve
	/// > new cells with ``SheetView/dequeueReusableCell(withIdentifier:)``.
	///
	/// > Default implementation returns an empty ``SheetViewCell``, so make sure to override this method if
	/// > ``sheetNumberOfFixedRows(_:in:)-6df4k`` is non zero.
	func sheet(_ sheet: SheetView, cellForFixedRowAt index: SheetIndex, in area: SheetViewArea) -> SheetViewCell

	/// Implement this method and return an appropriate ``SheetViewCell`` or its subclass. Returned view will
	/// be placed in the fixed column `area` at a given index. Make sure to populate the necessary cell properties in this method.
	///
	/// - Parameter index: will have its `column` value set to the fixed column index.
	///
	/// > Resulting cell will be sized in accordance to its corresponding fixed column width and row height.
	///
	/// > For better performance utilize ``SheetView/register(_:forCellReuseIdentifier:)`` and retrieve
	/// > new cells with ``SheetView/dequeueReusableCell(withIdentifier:)``.
	///
	/// > Default implementation returns an empty ``SheetViewCell``, so make sure to override this method if
	/// > ``sheetNumberOfFixedColumns(_:in:)-25dwe`` is non zero.
	func sheet(_ sheet: SheetView, cellForFixedColumnAt index: SheetIndex, in area: SheetViewArea) -> SheetViewCell

	// MARK: - Column and Row Definition
	/// Override to provide initial content column widths for the sheet view. Will be called with `index` from zero to
	/// whatever ``sheetNumberOfColumns(_:)`` returned, non inclusive. Values, returned from this method
	/// will be used when laying out the sheet view content for the first time, or after a ``SheetView/reloadData()``
	/// is executed.
	///
	/// > If not overridden, the default width will be assigned to all columns.
	///
	/// > This method is not called for fixed columns. Fixed column widths are determined by
	/// > ``sheet(_:widthForFixedColumnAt:in:)-5qc0t``.
	func sheetColumnWidth(_ sheet: SheetView, at index: Int) -> CGFloat

	/// Override to provide initial content row heights for the sheet view. Will be called with `index` from zero to
	/// whatever ``sheetNumberOfRows(_:)`` returned, non inclusive. Values, returned from this method
	/// will be used when laying out the sheet view content for the first time, or after a ``SheetView/reloadData()``
	/// is executed.
	///
	/// > If not overridden, the default height will be assigned to all rows.
	///
	/// > This method is not called for fixed rows. Fixed column widths are determined by
	/// > ``sheet(_:heightForFixedRowAt:in:)-63xpx``.
	func sheetRowHeight(_ sheet: SheetView, at index: Int) -> CGFloat

	/// Provide the  column quantity to be rendered in the sheet view content area. This number is queried when the
	/// sheet view is laying out its initial content, or after  ``SheetView/reloadData()`` is called.
	func sheetNumberOfColumns(_ sheet: SheetView) -> Int

	/// Provide the  row quantity to be rendered in the sheet view content area. This number is queried when the
	/// sheet view is laying out its initial content, or after  ``SheetView/reloadData()`` is called.
	func sheetNumberOfRows(_ sheet: SheetView) -> Int

	/// Provide the amount of rows to be displayed in the fixed `area` for the spreadsheet. This number is queried when the
	/// sheet view is laying out its initial content, or after  ``SheetView/reloadData()`` is called. Returning a positive number
	/// will result in ``sheet(_:heightForFixedRowAt:in:)-63xpx`` to be called for each respective row.
	///
	/// > Default implementation returns zero for all fixed areas.
	func sheetNumberOfFixedRows(_ sheet: SheetView, in area: SheetViewArea) -> Int

	/// Provide the amount of columns to be displayed in the fixed `area` for the spreadsheet. This number is queried when the
	/// sheet view is laying out its initial content, or after  ``SheetView/reloadData()`` is called. Returning a positive number
	/// will result in ``sheet(_:widthForFixedColumnAt:in:)-5qc0t`` to be called for each respective column.
	///
	/// > Default implementation returns zero for all fixed areas.
	func sheetNumberOfFixedColumns(_ sheet: SheetView, in area: SheetViewArea) -> Int

	/// Determines the height for each individual fixed row in a given `area`.  Called
	/// ``sheetNumberOfFixedRows(_:in:)-40oxz`` times during the initial content layout phase, or after
	/// ``SheetView/reloadData()`` is executed.
	///
	/// > If not overridden, the default height will be assigned to all rows.
	func sheet(_ sheet: SheetView, heightForFixedRowAt index: Int, in area: SheetViewArea) -> CGFloat

	/// Determines the height for each individual fixed column in a given `area`.  Called
	/// ``sheetNumberOfFixedColumns(_:in:)-121lg`` times during the initial content layout phase, or after
	/// ``SheetView/reloadData()`` is executed.
	///
	/// > If not overridden, the default width will be assigned to all columns.
	func sheet(_ sheet: SheetView, widthForFixedColumnAt index: Int, in area: SheetViewArea) -> CGFloat

	// MARK: - Misc
	/// Override to provide the maximum amount of cells to be retained within each reuse queue. Called once for each
	/// queue created, right after ``SheetView/register(_:forCellReuseIdentifier:)`` is called. Return -1 to
	/// use the default queue limit.
	///
	/// > When overriding, it might be useful to return a small number, to reduce the amount of memory wasted
	/// > on cached cells, and/or lots of scrolling within the spreadsheet is not expected. It might be useful to return a larger number
	/// > if cell creation is an expensive process, and a considerable amount of fast scrolling is expected.
	func sheet(_ sheet: SheetView, queueLimitForReuseIdentifier reuseIdentifier: String) -> Int
}

// MARK: - Default Implemenetation
public extension SheetViewDataSource {
	// MARK: - View Production
	func sheet(_ sheet: SheetView, cellForFixedRowAt index: SheetIndex, in area: SheetViewArea) -> SheetViewCell {
		return .init()
	}

	func sheet(_ sheet: SheetView, cellForFixedColumnAt index: SheetIndex, in area: SheetViewArea) -> SheetViewCell {
		return .init()
	}

	func sheet(_ sheet: SheetView, editorCellFor index: SheetIndex) -> UIView? {
		return nil
	}

	// MARK: - Column and Row Definition
	func sheetColumnWidth(_ sheet: SheetView, at index: Int) -> CGFloat {
		return SheetView.defaultColWidth
	}

	func sheetRowHeight(_ sheet: SheetView) -> CGFloat {
		return SheetView.defaultRowHeight
	}

	func sheetNumberOfFixedRows(_ sheet: SheetView, in area: SheetViewArea) -> Int {
		return 0
	}

	func sheetNumberOfFixedColumns(_ sheet: SheetView, in area: SheetViewArea) -> Int {
		return 0
	}

	func sheet(_ sheet: SheetView, heightForFixedRowAt index: Int, in area: SheetViewArea) -> CGFloat {
		return SheetView.defaultRowHeight
	}

	func sheet(_ sheet: SheetView, widthForFixedColumnAt index: Int, in area: SheetViewArea) -> CGFloat {
		return SheetView.defaultColWidth
	}

	// MARK: - Misc
	func sheet(_ sheet: SheetView, queueLimitForReuseIdentifier reuseIdentifier: String) -> Int {
		return -1
	}
}
