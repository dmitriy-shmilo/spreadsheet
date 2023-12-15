//

import Foundation

/// Represents a 2D index within a table. Assigned to ``SheetViewCell``s and defines their position within the table.
public struct SheetIndex: Hashable {

	/// An invalid, undefined cell index.
	public static let invalid = SheetIndex(col: -1, row: -1, index: -1)

	/// Zero index. The most top-left position in the table.
	public static let zero = SheetIndex(col: 0, row: 0, index: 0)

	/// Cell column within the table. Zero-based. Column indices increase from left to right.
	public let col: Int

	/// Cell row within the table. Zero-based. Row indices increase from top to bottom.
	public let row: Int

	/// Cell position within a flattened representation of the table. Depends on the table width.
	/// > Note: This field is not used within the library at the moment, and exists only for convenience.
	/// > This might change in the future, so it's preferrable to create indices using ``SheetView/makeIndex(_:_:)``
	/// > or ``init(col:row:columnCount:)`` calls.
	public let index: Int

	public init(col: Int, row: Int, index: Int) {
		self.col = col
		self.row = row
		self.index = index
	}

	public init(col: Int, row: Int, columnCount: Int) {
		self.col = col
		self.row = row
		self.index = col + row * columnCount
	}
}

extension SheetIndex: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "{Index \(col), \(row), \(index)}"
	}
}
