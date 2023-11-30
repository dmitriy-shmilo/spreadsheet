//

import UIKit

public protocol SheetDataSource: AnyObject {
	// TODO: support variable column and row sizes
	func SheetColumnWidth(_ sheet: SheetView) -> CGFloat
	func SheetRowHeight(_ sheet: SheetView) -> CGFloat
	func SheetNumberOfColumns(_ sheet: SheetView) -> Int
	func SheetNumberOfRows(_ sheet: SheetView) -> Int
	func Sheet(_ sheet: SheetView, cellFor index: SheetIndex) -> UIView
}
