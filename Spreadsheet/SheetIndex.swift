//

import Foundation

public struct SheetIndex: Hashable {
	public static let invalid = SheetIndex(col: -1, row: -1, index: -1)
	public static let zero = SheetIndex(col: 0, row: 0, index: 0)

	public var col: Int
	public var row: Int
	public var index: Int
}

extension SheetIndex: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "{Index \(col), \(row), \(index)}"
	}
}
