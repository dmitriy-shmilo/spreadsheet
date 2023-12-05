//

import Foundation

struct SheetCellRange: Equatable {
	static let empty = SheetCellRange(
		leftColumn: 0, rightColumn: 0, topRow: 0, bottomRow: 0)
	let leftColumn: Int
	let rightColumn: Int
	let topRow: Int
	let bottomRow: Int
}
