//

import UIKit

public protocol SheetDataSource: AnyObject {
	func sheetColumnWidth(_ sheet: SheetView, at index: Int) -> CGFloat
	func sheetRowHeight(_ sheet: SheetView, at index: Int) -> CGFloat
	func sheetNumberOfColumns(_ sheet: SheetView) -> Int
	func sheetNumberOfRows(_ sheet: SheetView) -> Int
	func sheet(_ sheet: SheetView, cellFor index: SheetIndex) -> SheetViewCell
	func sheet(_ sheet: SheetView, queueLimitForReuseIdentifier reuseIdentifier: String) -> Int

	// MARK: - Sticky Rows and Columns
	func sheetNumberOfFixedTopRows(_ sheet: SheetView) -> Int
	func sheet(_ sheet: SheetView, heightForFixedTopRowAt index: Int) -> CGFloat
	func sheet(_ sheet: SheetView, cellFor column: Int, inFixedTopRow row: Int) -> SheetViewCell
}

extension SheetDataSource {
	func sheetColumnWidth(_ sheet: SheetView, at index: Int) -> CGFloat {
		return SheetView.defaultColWidth
	}

	func sheetRowHeight(_ sheet: SheetView) -> CGFloat {
		return SheetView.defaultRowHeight
	}

	func sheet(_ sheet: SheetView, queueLimitForReuseIdentifier reuseIdentifier: String) -> Int {
		return -1
	}

	func sheetNumberOfFixedTopRows(_ sheet: SheetView) -> Int {
		return 1
	}

	func sheet(_ sheet: SheetView, heightForFixedTopRowAt index: Int) -> CGFloat {
		return SheetView.defaultRowHeight
	}

	func sheet(_ sheet: SheetView, cellFor column: Int, inFixedTopRow row: Int) -> SheetViewCell {
		// TODO: reuse cells
		let cell = SheetViewCell()
		cell.normalBackgroundColor = .secondarySystemBackground
		return cell
	}
}
