//

import Foundation

public struct SheetViewSelectionMode: OptionSet {
	public var rawValue: UInt8

	public init(rawValue: UInt8) {
		self.rawValue = rawValue
	}

	public static let none = SheetViewSelectionMode([])
	public static let cell = SheetViewSelectionMode(rawValue: 1)
	public static let row = SheetViewSelectionMode(rawValue: 1 << 1)
	public static let column = SheetViewSelectionMode(rawValue: 1 << 2)
	public static let range = SheetViewSelectionMode(rawValue: 1 << 3)

	public static let all = [SheetViewSelectionMode.cell, .row, .column, .range]
}
