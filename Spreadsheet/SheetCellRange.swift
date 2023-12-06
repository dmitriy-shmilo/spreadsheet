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

extension SheetCellRange: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "{SheetCellRange leftColumn: \(leftColumn), topRow: \(topRow), rightColumn: \(rightColumn), bottomRow: \(bottomRow)}"
	}
}
