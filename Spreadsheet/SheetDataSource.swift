//

import UIKit

public protocol SheetDataSource: AnyObject {
	// TODO: support variable column and row sizes
	func sheetColumnWidth(_ sheet: SheetView) -> CGFloat
	func sheetRowHeight(_ sheet: SheetView) -> CGFloat
	func sheetNumberOfColumns(_ sheet: SheetView) -> Int
	func sheetNumberOfRows(_ sheet: SheetView) -> Int
	func sheet(_ sheet: SheetView, cellFor index: SheetIndex) -> SheetViewCell
}

extension SheetDataSource {
	func sheetColumnWidth(_ sheet: SheetView) -> CGFloat {
		return SheetView.defaultColWidth
	}

	func sheetRowHeight(_ sheet: SheetView) -> CGFloat {
		return SheetView.defaultRowHeight
	}
}
