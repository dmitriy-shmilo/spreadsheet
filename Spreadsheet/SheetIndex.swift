//

import Foundation

public struct SheetIndex: Hashable {
	var col: Int
	var row: Int
	var index: Int
}

extension SheetIndex: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "{Index \(col), \(row), \(index)}"
	}
}
