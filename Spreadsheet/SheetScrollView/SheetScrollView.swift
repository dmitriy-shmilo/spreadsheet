//

import UIKit

class SheetScrollView: UIScrollView {
	private static let selectionPadding = 16.0

	weak var sheet: SheetView!

	private var visibleCells = [SheetIndex: SheetViewCell]()
	private var leftColumn = 0
	private var rightColumn = 0
	private var topRow = 0
	private var bottomRow = 0
	private(set) var selection = SheetSelection.none {
		didSet {
			if oldValue != selection {
				sheet.delegate?.sheet(
					sheet,
					didChangeSelection: selection,
					from: oldValue)
			}
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}

		guard sheet.allowedSelectionModes.contains(.cell) else {
			return
		}

		let point = touch.location(in: self)
		guard let colIndex = sheet.columns[leftColumn..<rightColumn].first(where: {
			$0.offset <= point.x && ($0.offset + $0.width) >= point.x
		}) else {
			return
		}

		guard let rowIndex = sheet.rows[topRow..<bottomRow].first(where: {
			$0.offset <= point.y && ($0.offset + $0.height) >= point.y
		}) else {
			return
		}
		let cellIndex = sheet.makeIndex(colIndex.index, rowIndex.index)

		deselectCellsAt(selection)
		selection = .cell(column: colIndex.index, row: rowIndex.index)

		if sheet.delegate?.sheet(sheet, shouldSelectCellAt: cellIndex) ?? true {
			selectCellsAt(selection)
		} else {
			selection = .none
		}
	}

	override var contentOffset: CGPoint {
		didSet {
			guard let sheet = sheet else {
				return
			}

			let topLeft = contentOffset
			let bottomRight = CGPoint(x: contentOffset.x + frame.width,
									  y: contentOffset.y + frame.height)
			let cols = sheet.columns
			let rows = sheet.rows

			// TODO: For a relatively small number of columns the following
			// linear search will perform OK. But for a large number of
			// columns we should leverage the fact that sheet.columns
			// is sorted by offset, and use binary search.

			// find the leftmost and rightmost visible column indicies
			let leftIndex = cols.firstIndex {
				$0.offset <= topLeft.x && $0.offset + $0.width >= topLeft.x
			} ?? 0
			let rightIndex = cols.firstIndex {
				$0.offset <= bottomRight.x && $0.offset + $0.width >= bottomRight.x
			} ?? sheet.columns.count - 1

			// find the top and bottom visible row indices
			let topIndex = rows.firstIndex {
				$0.offset <= topLeft.y && $0.offset + $0.height >= topLeft.y
			} ?? 0
			let bottomIndex = rows.firstIndex {
				$0.offset <= bottomRight.y && $0.offset + $0.height >= bottomRight.y
			} ?? sheet.rows.count - 1

			leftColumn = max(0, leftIndex - 1)
			rightColumn = min(cols.count, rightIndex + 1)
			topRow = max(0, topIndex - 1)
			bottomRow = min(rows.count, bottomIndex + 1)

			for index in visibleCells.keys {
				if index.col < leftColumn || index.col > rightColumn
					|| index.row < topRow || index.row > bottomRow {
					if let cell = visibleCells.removeValue(forKey: index) {
						sheet.releaseCell(cell)
					}
				}
			}

			for x in leftColumn..<rightColumn {
				for y in topRow..<bottomRow {
					let index = sheet.makeIndex(x, y)
					if visibleCells[index] == nil {
						let cell = sheet.cellFor(index, in: .content)
						addSubview(cell)
						cell.frame = .init(
							x: cols[x].offset,
							y: rows[y].offset,
							width: cols[x].width,
							height: rows[y].height)
						visibleCells[index] = cell
					}
				}
			}
		}
	}

	func reloadCellsAt(indices: [SheetIndex]) {
		for i in indices {
			if let cell = visibleCells[i] {
				let frame = cell.frame
				sheet.releaseCell(cell)
				let freshCell = sheet.cellFor(i, in: .content)
				addSubview(freshCell)
				freshCell.frame = frame
				visibleCells[i] = freshCell
			}
		}
	}

	// MARK: - Selection Operations
	func setSelection(_ selection: SheetSelection, animated: Bool) {
		deselectCellsAt(selection)
		self.selection = selection
		selectCellsAt(selection)
		scrollToSelection(selection, animated: true)
	}

	func deselectCellsAt(_ selection: SheetSelection) {
		for i in visibleIndicesFrom(selection: selection) {
			visibleCells[i]?.selection = .none
		}
	}

	func selectCellsAt(_ selection: SheetSelection) {
		var rect = CGRect.zero
		for i in visibleIndicesFrom(selection: selection) {
			if let cell = visibleCells[i] {
				cell.selection = selection
				if rect == .zero {
					rect = cell.frame
				} else {
					rect = rect.union(cell.frame)
				}
			}
		}

		if rect != .zero {
			rect = rect.insetBy(dx: -Self.selectionPadding, dy: -Self.selectionPadding)
			scrollRectToVisible(rect, animated: true)
		}
	}

	func scrollToSelection(_ selection: SheetSelection, animated: Bool) {
		let allowedCols = 0..<sheet.columns.count
		let allowedRows = 0..<sheet.rows.count
		switch selection {
		case .none:
			return
		case .cell(let column, let row)
			where allowedCols.contains(column) && allowedRows.contains(row):
			let colDef = sheet.columns[column]
			let rowDef = sheet.rows[row]
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
			let leftColDef = sheet.columns[left]
			let rightColDef = sheet.columns[right]
			let topRowDef = sheet.rows[top]
			let bottomRowDef = sheet.rows[bottom]

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

	func refreshContentMeasurements() {
		// TODO: cache the total width and height
		contentSize = .init(
			width: sheet.columns.map { $0.width }.reduce(0.0, +),
			height: sheet.rows.map { $0.height }.reduce(0.0, +))
	}

	private func visibleIndicesFrom(selection: SheetSelection) -> [SheetIndex] {
		switch selection {
		case .none:
			return []
		case .column(let col):
			return (topRow..<bottomRow).map {
				self.sheet.makeIndex(col, $0)
			}
		case .row(let row):
			return (leftColumn..<rightColumn).map {
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