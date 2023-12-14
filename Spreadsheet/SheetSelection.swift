//

import Foundation

public enum SheetSelection: Equatable {
	case none
	case columnSet(indices: IndexSet)
	case columnRange(from: Int, to: Int)
	case rowSet(indices: IndexSet)
	case rowRange(from: Int, to: Int)
	case cellSet(indices: Set<SheetIndex>)
	case cellRange(left: Int, top: Int, right: Int, bottom: Int)
}

// MARK: - Convenience Functions
extension SheetSelection {
	public static func singleColumn(with index: Int) -> SheetSelection {
		return .columnSet(indices: .init(integer: index))
	}

	public static func singleRow(with index: Int) -> SheetSelection {
		return .rowSet(indices: .init(integer: index))
	}

	public static func singleCell(with index: SheetIndex) -> SheetSelection {
		return .cellSet(indices: .init(arrayLiteral: index))
	}
}

// MARK: - Utility
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
		case .cellSet(let indices):
			return indices.contains(index)
		case .cellRange(let left, let top, let right, let bottom):
			return left <= index.col && right >= index.col
			&& top <= index.row && bottom >= index.row
		}
	}
}
