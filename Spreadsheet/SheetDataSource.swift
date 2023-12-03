//

import UIKit

public protocol SheetDataSource: AnyObject {
	func sheetColumnWidth(_ sheet: SheetView, at index: Int) -> CGFloat
	func sheetRowHeight(_ sheet: SheetView) -> CGFloat
	func sheetNumberOfColumns(_ sheet: SheetView) -> Int
	func sheetNumberOfRows(_ sheet: SheetView) -> Int
	func sheet(_ sheet: SheetView, cellFor index: SheetIndex) -> SheetViewCell
	func sheet(_ sheet: SheetView, queueLimitForReuseIdentifier reuseIdentifier: String) -> Int
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
}
