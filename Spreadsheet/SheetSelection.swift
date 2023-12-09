//

import Foundation

public enum SheetSelection: Equatable {
	case none
	case columnSet(indices: IndexSet)
	case columnRange(from: Int, to: Int)
	case row(index: Int)
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
		case .row(let row):
			return row == index.row
		case .cell(let col, let row):
			return col == index.col && row == index.row
		case .range(let left, let top, let right, let bottom):
			return left <= index.col && right >= index.col
			&& top <= index.row && bottom >= index.row
		}
	}
}
