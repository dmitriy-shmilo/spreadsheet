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
			releaseCells(outside: visibleRange)
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

	func invalidateContentSize() {
		guard let row = rows.last,
			  let column = columns.last else {
			contentSize = .zero
			return
		}

		contentSize = .init(
			width: column.offset + column.width,
			height: row.offset + row.height)
	}

	// MARK: - Cell Lifecycle
	func reloadData() {
		releaseAllCells()
		let oldRange = visibleRange
		invalidateContentSize()

		if oldRange.topRow != visibleRange.topRow
			|| oldRange.leftColumn != visibleRange.leftColumn {
			contentOffset = .init(
				x: columns[oldRange.leftColumn].offset,
				y: rows[oldRange.topRow].offset)
		} else {
			addCells(in: visibleRange)
		}
	}

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

	func releaseCells(outside range: SheetCellRange) {
		for index in visibleCells.keys {
			if !range.contains(index: index) {
				if let cell = visibleCells.removeValue(forKey: index) {
					sheet.releaseCell(cell)
				}
			}
		}
	}

	func releaseCells(in range: SheetCellRange) {
		for index in visibleCells.keys {
			if range.contains(index: index) {
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

	// MARK: - Column/Row Utility
	func findColumnIntersecting(offset: CGFloat) -> SheetColumnDefinition? {
		return columns.binarySearch {
			if $0.offset > offset {
				return .orderedAscending
			}

			if $0.offset + $0.width < offset {
				return .orderedDescending
			}

			return .orderedSame
		}
	}

	func findRowIntersecting(offset: CGFloat) -> SheetRowDefinition? {
		return rows.binarySearch {
			if $0.offset > offset {
				return .orderedAscending
			}

			if $0.offset + $0.height < offset {
				return .orderedDescending
			}

			return .orderedSame
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

	// MARK: - Selection Utility
	func isSelectionSupported(_ selection: SheetSelection) -> Bool {
		return true
	}

	func setSelection(_ selection: SheetSelection) {
		clearSelection()

		if isSelectionSupported(selection) {
			self.selection = selection
			selectCellsAt(selection)
		} else {
			self.selection = .none
		}
	}

	func clearSelection() {
		for cell in visibleCells.values {
			cell.selection = .none
		}
	}

	func deselectCellsAt(_ selection: SheetSelection) {
		for i in visibleIndicesFrom(selection: selection) {
			visibleCells[i]?.selection = .none
		}
	}

	func selectCellsAt(_ selection: SheetSelection) {
		for i in visibleIndicesFrom(selection: selection) {
			if let cell = visibleCells[i] {
				cell.selection = selection
			}
		}
	}
	
	func scrollToSelection(_ selection: SheetSelection, animated: Bool) {
		switch selection {
		case .none:
			return

		case .columnSet(let indices):
			let firstIndex = indices.reduce(Int.max, min)
			let lastIndex = indices.reduce(0, max)
			scrollToColumnRange(from: firstIndex, to: lastIndex, animated: animated)

		case .columnRange(let from, let to):
			scrollToColumnRange(from: from, to: to, animated: animated)

		case .rowSet(let indices):
			let firstIndex = indices.reduce(Int.max, min)
			let lastIndex = indices.reduce(0, max)
			scrollToRowRange(from: firstIndex, to: lastIndex, animated: animated)

		case .rowRange(let from, let to):
			scrollToRowRange(from: from, to: to, animated: animated)

		case .cellSet(let indices):
			let left = indices
				.map { $0.col }
				.reduce(Int.max, min)
			let right = indices
				.map { $0.col }
				.reduce(0, max)
			let top = indices
				.map { $0.row }
				.reduce(Int.max, min)
			let bottom = indices
				.map { $0.row }
				.reduce(0, max)
			scrollToCellRange(
				left: left,
				top: top,
				right: right,
				bottom: bottom,
				animated: animated)
		case .cellRange(let left, let top, let right, let bottom):
			scrollToCellRange(
				left: left,
				top: top,
				right: right,
				bottom: bottom,
				animated: animated)
		}
	}

	func visibleIndicesFrom(selection: SheetSelection) -> [SheetIndex] {
		switch selection {
		case .none:
			return []
		case .columnSet(let indices):
			var result = [SheetIndex]()
			for col in indices {
				if visibleRange.columnRange.contains(col) {
					for row in visibleRange.rowRange {
						result.append(sheet.makeIndex(col, row))
					}
				}
			}
			return result
		case .columnRange(let from, let to):
			var result = [SheetIndex]()
			for col in (from..<to + 1).clamped(to: visibleRange.columnRange) {
				for row in visibleRange.rowRange {
					result.append(sheet.makeIndex(col, row))
				}
			}
			return result
		case .rowSet(let indices):
			var result = [SheetIndex]()
			for row in indices {
				if visibleRange.rowRange.contains(row) {
					for col in visibleRange.columnRange {
						result.append(sheet.makeIndex(col, row))
					}
				}
			}
			return result
		case .rowRange(let from, let to):
			var result = [SheetIndex]()
			for row in (from..<to + 1).clamped(to: visibleRange.rowRange) {
				for col in visibleRange.columnRange {
					result.append(sheet.makeIndex(col, row))
				}
			}
			return result
		case .cellSet(let indices):
			return Array(indices.intersection(visibleCells.keys))
		case .cellRange(let left, let top, let right, let bottom):
			var result = [SheetIndex]()
			for row in (top..<bottom + 1).clamped(to: visibleRange.rowRange) {
				for col in (left..<right + 1).clamped(to: visibleRange.columnRange) {
					result.append(sheet.makeIndex(col, row))
				}
			}
			return result
		}
	}

	// MARK: - Private Methods
	// MARK: Scrolling
	private func scrollToColumnRange(from: Int, to: Int, animated: Bool) {
		let allowedCols = 0..<columns.count
		guard allowedCols.contains(from) && allowedCols.contains(to) else {
			return
		}

		let rect = CGRect(
			x: columns[from].offset - Self.selectionPadding,
			y: contentOffset.y,
			width: columns[to].offset - columns[from].offset + columns[to].width + Self.selectionPadding * 2.0,
			height: frame.height)
			.limitedBy(size: frame.size)

		scrollRectToVisible(rect, animated: animated)
	}

	private func scrollToRowRange(from: Int, to: Int, animated: Bool) {
		let allowedRows = 0..<rows.count
		guard allowedRows.contains(from) && allowedRows.contains(to) else {
			return
		}

		let rect = CGRect(
			x: contentOffset.x,
			y: rows[from].offset - Self.selectionPadding,
			width: frame.width,
			height: rows[to].offset - rows[from].offset + rows[to].height + Self.selectionPadding * 2.0)
			.limitedBy(size: frame.size)

		scrollRectToVisible(rect, animated: animated)
	}

	private func scrollToCellRange(
		left: Int, top: Int, right: Int, bottom: Int, animated: Bool) {
		let allowedCols = 0..<columns.count
		let allowedRows = 0..<rows.count

		guard allowedCols.contains(left)
				&& allowedCols.contains(right)
				&& allowedRows.contains(top)
				&& allowedRows.contains(bottom) else {
			return
		}

		let leftColDef = columns[left]
		let rightColDef = columns[right]
		let topRowDef = rows[top]
		let bottomRowDef = rows[bottom]

		let rect = CGRect(x: leftColDef.offset,
						  y: topRowDef.offset,
						  width: rightColDef.offset + rightColDef.width - leftColDef.offset,
						  height: bottomRowDef.offset + bottomRowDef.height - topRowDef.offset)
			.insetBy(dx: -Self.selectionPadding, dy: -Self.selectionPadding)
			.limitedBy(size: frame.size)
		scrollRectToVisible(rect, animated: animated)
	}
}


