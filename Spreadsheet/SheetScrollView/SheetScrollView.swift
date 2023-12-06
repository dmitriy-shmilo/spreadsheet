//

import UIKit

class SheetScrollView: UIScrollView {
	static let selectionPadding = 16.0
	weak var sheet: SheetView!

	var columns = [SheetColumnDefinition]()
	var rows = [SheetRowDefinition]()
	var selection = SheetSelection.none
	var visibleCells = [SheetIndex: SheetViewCell]()
	var visibleRange = SheetCellRange.empty
	var area = SheetViewArea.unknown

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override var contentOffset: CGPoint {
		didSet {
			let range = determineVisibleRange()

			guard visibleRange != range else {
				return
			}

			visibleRange = range
			releaseCells(in: visibleRange)
			addCells(in: visibleRange)
		}
	}

	func determineRange(from topLeft: CGPoint, to bottomRight: CGPoint) -> SheetCellRange {
		fatalError("determineVisibleRange is not implemented")
	}

	func determineVisibleRange() -> SheetCellRange {
		return determineRange(
			from: contentOffset,
			to: .init(
				x: contentOffset.x + bounds.width,
				y: contentOffset.y + bounds.height))
	}
}

extension SheetScrollView {
	func reloadVisibleCells() {
		releaseCells(in: visibleRange)
		visibleRange = determineVisibleRange()
		addCells(in: visibleRange)
	}

	func releaseAllCells() {
		for cell in visibleCells.values {
			sheet.releaseCell(cell)
		}
		visibleCells.removeAll(keepingCapacity: true)
	}

	func releaseCells(in range: SheetCellRange) {
		for index in visibleCells.keys {
			if index.col < range.leftColumn || index.col > range.rightColumn
				|| index.row < range.topRow || index.row > range.bottomRow {
				if let cell = visibleCells.removeValue(forKey: index) {
					sheet.releaseCell(cell)
				}
			}
		}
	}

	func addCells(in range: SheetCellRange) {
		for x in range.leftColumn..<range.rightColumn {
			for y in range.topRow..<range.bottomRow {
				let index = sheet.makeIndex(x, y)
				if visibleCells[index] == nil {
					let cell = sheet.cellFor(index, in: area)
					addSubview(cell)
					cell.frame = .init(
						x: columns[x].offset,
						y: rows[y].offset,
						width: columns[x].width,
						height: rows[y].height)
					visibleCells[index] = cell
				}
			}
		}
	}
}
// MARK: - Column/Row Utility
extension SheetScrollView {
	// TODO: For a relatively small number of columns the following
	// linear search will perform OK. But for a large number of
	// columns we should leverage the fact that columns and rows
	// are sorted by offset, and use binary search.

	func findColumnIntersecting(offset: CGFloat) -> SheetColumnDefinition? {
		return columns.first {
			$0.offset <= offset && $0.offset + $0.width >= offset
		}
	}

	func findRowIntersecting(offset: CGFloat) -> SheetRowDefinition? {
		return rows.first {
			$0.offset <= offset && $0.offset + $0.height >= offset
		}
	}

	func findVisibleColumnIntersecting(offset: CGFloat) -> SheetColumnDefinition? {
		return columns[visibleRange.leftColumn..<visibleRange.rightColumn].first {
			$0.offset <= offset && $0.offset + $0.width >= offset
		}
	}

	func findVisibleRowIntersecting(offset: CGFloat) -> SheetRowDefinition? {
		return rows[visibleRange.topRow..<visibleRange.bottomRow].first {
			$0.offset <= offset && $0.offset + $0.height >= offset
		}
	}
}

// MARK: - Selection Utility
extension SheetScrollView {
	func scrollToSelection(_ selection: SheetSelection, animated: Bool) {
		let allowedCols = 0..<columns.count
		let allowedRows = 0..<rows.count
		switch selection {
		case .none:
			return
		case .cell(let column, let row)
			where allowedCols.contains(column) && allowedRows.contains(row):
			let colDef = columns[column]
			let rowDef = rows[row]
			let rect = CGRect(x: colDef.offset,
							  y: rowDef.offset,
							  width: colDef.width,
							  height: rowDef.height)
				.insetBy(dx: -Self.selectionPadding, dy: -Self.selectionPadding)
			scrollRectToVisible(rect, animated: animated)
		case .cell(_, _):
			return
		case .column(_):
			fatalError("Not implemented")
		case .row(_):
			fatalError("Not implemented")
		case .range(let left, let top, let right, let bottom)
			where allowedCols.contains(left) && allowedCols.contains(right)
			&& allowedRows.contains(top) && allowedRows.contains(bottom):
			let leftColDef = columns[left]
			let rightColDef = columns[right]
			let topRowDef = rows[top]
			let bottomRowDef = rows[bottom]

			let rect = CGRect(x: leftColDef.offset,
							  y: topRowDef.offset,
							  width: rightColDef.offset + rightColDef.width - leftColDef.offset,
							  height: bottomRowDef.offset + bottomRowDef.height - topRowDef.offset)
				.insetBy(dx: -Self.selectionPadding, dy: -Self.selectionPadding)
			scrollRectToVisible(rect, animated: animated)
		case .range(_, _, _, _):
			return
		}
	}

	func reloadData() {
		releaseAllCells()
		guard let row = rows.last,
			  let column = columns.last else {
			contentSize = .zero
			return
		}

		let oldRange = visibleRange
		contentSize = .init(
			width: column.offset + column.width,
			height: row.offset + row.height)

		if oldRange.topRow != visibleRange.topRow
			|| oldRange.leftColumn != visibleRange.leftColumn {
			contentOffset = .init(
				x: columns[oldRange.leftColumn].offset,
				y: rows[oldRange.topRow].offset)
		} else {
			addCells(in: visibleRange)
		}
	}

	func visibleIndicesFrom(selection: SheetSelection) -> [SheetIndex] {
		switch selection {
		case .none:
			return []
		case .column(let col):
			return (visibleRange.topRow..<visibleRange.bottomRow).map {
				self.sheet.makeIndex(col, $0)
			}
		case .row(let row):
			return (visibleRange.leftColumn..<visibleRange.rightColumn).map {
				self.sheet.makeIndex($0, row)
			}
		case .cell(let col, let row):
			return [sheet.makeIndex(col, row)]
		case .range(let left, let top, let right, let bottom):
			return (left..<right).flatMap { col in
				(top..<bottom).map { row in
					self.sheet.makeIndex(col, row)
				}
			}
		}
	}
}
