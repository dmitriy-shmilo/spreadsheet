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

extension SheetCellRange {
	func contains(column: Int) -> Bool {
		return leftColumn <= column && rightColumn >= column
	}

	func contains(row: Int) -> Bool {
		return topRow <= row && bottomRow >= row
	}

	func contains(index: SheetIndex) -> Bool {
		return leftColumn <= index.col && rightColumn >= index.col
		&& topRow <= index.row && bottomRow >= index.row
	}
}
