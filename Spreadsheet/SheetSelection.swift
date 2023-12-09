//

import Foundation

public enum SheetSelection: Equatable {
	case none
	case columnSet(indices: IndexSet)
	case columnRange(from: Int, to: Int)
	case rowSet(indices: IndexSet)
	case rowRange(from: Int, to: Int)
	case cell(column: Int, row: Int)
	case range(left: Int, top: Int, right: Int, bottom: Int)
}

extension SheetSelection {
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
		case .cell(let col, let row):
			return col == index.col && row == index.row
		case .range(let left, let top, let right, let bottom):
			return left <= index.col && right >= index.col
			&& top <= index.row && bottom >= index.row
		}
	}
}
