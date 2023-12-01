//

import Foundation

public struct SheetSelectionMode: OptionSet {
	public var rawValue: UInt8

	public init(rawValue: UInt8) {
		self.rawValue = rawValue
	}

	public static let none = SheetSelectionMode([])
	public static let cell = SheetSelectionMode(rawValue: 1)
	public static let row = SheetSelectionMode(rawValue: 1 << 1)
	public static let column = SheetSelectionMode(rawValue: 1 << 2)
	public static let range = SheetSelectionMode(rawValue: 1 << 3)

	public static let all = [SheetSelectionMode.cell, .row, .column, .range]
}
