//

import UIKit

public protocol SpreadsheetDataSource: AnyObject {
	// TODO: support variable column and row sizes
	func spreadsheetColumnWidth(_ sheet: SpreadsheetView) -> CGFloat
	func spreadsheetRowHeight(_ sheet: SpreadsheetView) -> CGFloat
	func spreadsheetNumberOfColumns(_ sheet: SpreadsheetView) -> Int
	func spreadsheetNumberOfRows(_ sheet: SpreadsheetView) -> Int
	func spreadsheet(_ sheet: SpreadsheetView, cellFor index: SpreadsheetIndex) -> UIView
}
