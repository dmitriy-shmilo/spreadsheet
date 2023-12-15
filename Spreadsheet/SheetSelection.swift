//

import Foundation

/// Defines a cell selection within a spreadsheet table.
public enum SheetSelection: Equatable {
	/// Empty selection.
	case none

	/// A set of columns is selected. All cells from the top to bottom within each column, including cells within fixed
	/// rows are selected. For single column selection provide an index set with a single value or use
	/// ``SheetSelection/singleColumn(with:)`` convenience method.
	case columnSet(indices: IndexSet)

	/// A range of columns selection. All columns from `from` parameter to `to` (inclusive) parameter are
	/// considered to be selected. All cells from the top to bottom within each column, including cells within fixed
	/// rows are selected.
	case columnRange(from: Int, to: Int)

	/// A set of rows selection. All cells from the left-most to the right-most one within each row, including cells within fixed
	/// columns are selected. For single row selection provide an index set with a single value or use
	/// ``SheetSelection/singleRow(with:)`` convenience method.
	case rowSet(indices: IndexSet)

	/// A range of rows selection. All rows from `from` parameter to `to` (inclusive) parameter are
	/// considered to be selected. All cells from the left to right within each column, including cells within fixed
	/// columns are selected.
	case rowRange(from: Int, to: Int)

	/// An arbitrary set of cells selection. All content cells within the provided `indices` paramter are considered selected.
	/// Doesn't affect cells within fixed rows and columns. Provide a set with a single value
	/// or use ``SheetSelection/singleCell(with:)`` to define a single cell  selection.
	case cellSet(indices: Set<SheetIndex>)

	/// Defines a selection of a set of content cells within a rectangular area defined by `left, top, right` and `bottom`
	/// parameters (inclusive on all sides). Does not affect cells within fixed rows and columns.
	case cellRange(left: Int, top: Int, right: Int, bottom: Int)
}

// MARK: - Convenience Functions
extension SheetSelection {
	/// A convenience creation method, which produces a ``columnSet(indices:)`` with a single index in it.
	public static func singleColumn(with index: Int) -> SheetSelection {
		return .columnSet(indices: .init(integer: index))
	}

	/// A convenience creation method, which produces a ``rowSet(indices:)`` with a single index in it.
	public static func singleRow(with index: Int) -> SheetSelection {
		return .rowSet(indices: .init(integer: index))
	}

	/// A convenience creation method, which produces a ``cellSet(indices:)`` with a single index in it.
	public static func singleCell(with index: SheetIndex) -> SheetSelection {
		return .cellSet(indices: .init(arrayLiteral: index))
	}
}

// MARK: - Utility
extension SheetSelection {
	/// - Returns: True if the provided `index` is contained within this selection.
	public func contains(_ index: SheetIndex) -> Bool {
		switch self {
		case .none:
			return false
		case .columnSet(let indices):
			return indices.contains(index.col)
		case .columnRange(let from, let to):
			return index.col >= from && index.col <= to
		case .rowSet(let indices):
			return indices.contains(index.row)
		case .rowRange(let from, let to):
			return index.row >= from && index.row <= to
		case .cellSet(let indices):
			return indices.contains(index)
		case .cellRange(let left, let top, let right, let bottom):
			return left <= index.col && right >= index.col
			&& top <= index.row && bottom >= index.row
		}
	}
}
