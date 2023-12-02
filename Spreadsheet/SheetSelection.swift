//

import Foundation

public enum SheetSelection: Equatable {
	case none
	case column(index: Int)
	case row(index: Int)
	case cell(column: Int, row: Int)
	case range(left: Int, top: Int, right: Int, bottom: Int)
}

extension SheetSelection {
	func contains(_ index: SheetIndex) -> Bool {
		switch self {
		case .none:
			return false
		case .column(let col):
			return col == index.col
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
