//

import Foundation

/// An option set, which describes allowed selection types for a spreadsheet table.
/// Used by the default ``SheetViewDelegate`` implementation.
public struct SheetViewSelectionMode: OptionSet {
	public var rawValue: UInt8

	public init(rawValue: UInt8) {
		self.rawValue = rawValue
	}

	public static let none = SheetViewSelectionMode([])
	public static let cell = SheetViewSelectionMode(rawValue: 1)
	public static let row = SheetViewSelectionMode(rawValue: 1 << 1)
	public static let column = SheetViewSelectionMode(rawValue: 1 << 2)

	public static let all = [SheetViewSelectionMode.cell, .row, .column]
}
