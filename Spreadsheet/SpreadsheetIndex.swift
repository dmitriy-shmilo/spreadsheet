//

import Foundation

public struct SpreadsheetIndex: Hashable {
	var col: Int
	var row: Int
	var index: Int
}

extension SpreadsheetIndex: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "{Index \(col), \(row), \(index)}"
	}
}
