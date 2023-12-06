//

import UIKit

public protocol SheetDataSource: AnyObject {
	func sheet(_ sheet: SheetView, queueLimitForReuseIdentifier reuseIdentifier: String) -> Int

	// MARK: - View Creation
	func sheet(_ sheet: SheetView, cellFor index: SheetIndex) -> SheetViewCell
	func sheet(_ sheet: SheetView, editorCellFor index: SheetIndex) -> UIView?

	// MARK: - Column and Row Definition
	func sheetColumnWidth(_ sheet: SheetView, at index: Int) -> CGFloat
	func sheetRowHeight(_ sheet: SheetView, at index: Int) -> CGFloat
	func sheetNumberOfColumns(_ sheet: SheetView) -> Int
	func sheetNumberOfRows(_ sheet: SheetView) -> Int

	// MARK: - Sticky Rows and Columns
	func sheetNumberOfFixedRows(_ sheet: SheetView, in area: SheetViewArea) -> Int
	func sheetNumberOfFixedColumns(_ sheet: SheetView, in area: SheetViewArea) -> Int
	func sheet(_ sheet: SheetView, heightForFixedRowAt index: Int, in area: SheetViewArea) -> CGFloat
	func sheet(_ sheet: SheetView, widthForFixedColumnAt index: Int, in area: SheetViewArea) -> CGFloat
	func sheet(_ sheet: SheetView, cellForFixedRowAt index: SheetIndex, in area: SheetViewArea) -> SheetViewCell
	func sheet(_ sheet: SheetView, cellForFixedColumnAt index: SheetIndex, in area: SheetViewArea) -> SheetViewCell
}

public extension SheetDataSource {
	func sheetColumnWidth(_ sheet: SheetView, at index: Int) -> CGFloat {
		return SheetView.defaultColWidth
	}

	func sheetRowHeight(_ sheet: SheetView) -> CGFloat {
		return SheetView.defaultRowHeight
	}

	func sheet(_ sheet: SheetView, queueLimitForReuseIdentifier reuseIdentifier: String) -> Int {
		return -1
	}

	func sheet(_ sheet: SheetView, editorCellFor index: SheetIndex) -> UIView? {
		return nil
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

	func sheet(_ sheet: SheetView, cellForFixedRowAt index: SheetIndex, in area: SheetViewArea) -> SheetViewCell {
		return .init()
	}
	
	func sheet(_ sheet: SheetView, cellForFixedColumnAt index: SheetIndex, in area: SheetViewArea) -> SheetViewCell {
		return .init()
	}

}
