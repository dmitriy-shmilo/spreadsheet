//

import UIKit

struct SheetColumnDefinition {
	var index: Int = -1
	var width: CGFloat = 0.0
	var offset: CGFloat = 0.0
}

struct SheetRowDefinition {
	var index: Int = -1
	var height: CGFloat = 0.0
	var offset: CGFloat = 0.0
}

public enum SheetViewArea {
	case unknown
	case content
	case fixedTop
	case fixedLeft
}

@IBDesignable
public class SheetView: UIView {
	static let minQueueLimit = 100
	static let defaultColWidth: CGFloat = 100.0
	static let defaultRowHeight: CGFloat = 45.0

	public weak var dataSource: SheetDataSource?

	public weak var delegate: SheetViewDelegate?
	public var selection: SheetSelection {
		get {
			return contentScrollView.selection
		}
	}

	public var allowedSelectionModes = SheetSelectionMode.all

	var columns = [SheetColumnDefinition]()
	var rows = [SheetRowDefinition]()
	var fixedTopRows = [SheetRowDefinition]()
	var fixedLeftColumns = [SheetColumnDefinition]()

	private var topScrollView: SheetFixedHorizontalScrollView!
	private var topScrollViewHeight: NSLayoutConstraint!
	private var leftScrollView: SheetFixedHorizontalScrollView!
	private var leftScrollViewWidth: NSLayoutConstraint!
	private var contentScrollView: SheetContentScrollView!
	private var syncContentOffsets = true

	private var cellQueues = [String: SheetViewCellQueue]()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	public func setSelection(_ selection: SheetSelection) {
		switch selection {
		case .columnRange(_, _),  .columnSet(_):
			topScrollView.setSelection(selection)
			leftScrollView.deselectCellsAtCurrentSelection()
			contentScrollView.setSelection(selection)
		default:
			topScrollView.deselectCellsAtCurrentSelection()
			leftScrollView.deselectCellsAtCurrentSelection()
			contentScrollView.setSelection(selection)
		}
	}

	public func scrollToSelection(_ selection: SheetSelection, animated: Bool) {
		contentScrollView.scrollToSelection(selection, animated: animated)
	}

	public func makeIndex(_ col: Int, _ row: Int) -> SheetIndex {
		return .init(col: col, row: row, index: row * columns.count + col)
	}

	public func frameRectFor(index: SheetIndex) -> CGRect {
		guard index.row >= 0 && index.row < rows.count
				&& index.col >= 0 && index.col < columns.count else {
			return .zero
		}

		return .init(
			x: columns[index.col].offset,
			y: rows[index.row].offset,
			width: columns[index.col].width,
			height: rows[index.row].height)
	}

	public func setWidth(_ width: CGFloat, for index: Int) {
		guard index >= 0 && index < columns.count else {
			return
		}

		let range = contentScrollView.visibleRange
		columns[index].width = width

		if index < columns.count - 1 {
			var offset = columns[index].offset + columns[index].width
			for i in (index + 1)..<columns.count {
				columns[i].offset = offset
				offset += columns[i].width
			}
		}

		contentScrollView.columns = columns
		topScrollView.columns = columns

		if range.rightColumn > index {
			syncContentOffsets = false

			// TODO: there's no real need to fully reload affected cells
			// we can just shift their frames by a given amount
			let contentRange = SheetCellRange(
				leftColumn: index,
				rightColumn: range.rightColumn,
				topRow: range.topRow,
				bottomRow: range.bottomRow)

			contentScrollView.releaseCells(in: contentRange)
			contentScrollView.addCells(in: contentRange)
			contentScrollView.invalidateContentSize()

			let topRange = SheetCellRange(
				leftColumn: index,
				rightColumn: range.rightColumn,
				topRow: 0,
				bottomRow: fixedTopRows.count)
			topScrollView.releaseCells(in: topRange)
			topScrollView.addCells(in: topRange)
			topScrollView.invalidateContentSize()

			syncContentOffsets = true
		}
	}

	private func setup() {
		topScrollView = .init(frame: .zero)
		topScrollView.translatesAutoresizingMaskIntoConstraints = false
		topScrollView.sheet = self
		topScrollView.delegate = self
		topScrollView.area = .fixedTop
		topScrollView.showsVerticalScrollIndicator = false
		topScrollView.showsHorizontalScrollIndicator = false
		topScrollViewHeight = topScrollView.heightAnchor.constraint(equalToConstant: 0.0)
		addSubview(topScrollView)

		leftScrollView = .init(frame: .zero)
		leftScrollView.translatesAutoresizingMaskIntoConstraints = false
		leftScrollView.sheet = self
		leftScrollView.delegate = self
		leftScrollView.area = .fixedLeft
		leftScrollView.showsVerticalScrollIndicator = false
		leftScrollView.showsHorizontalScrollIndicator = false
		leftScrollViewWidth = leftScrollView.widthAnchor.constraint(equalToConstant: 0.0)
		addSubview(leftScrollView)

		contentScrollView = .init(frame: .zero)
		contentScrollView.translatesAutoresizingMaskIntoConstraints = false
		contentScrollView.sheet = self
		contentScrollView.delegate = self
		contentScrollView.area = .content
		addSubview(contentScrollView)

		NSLayoutConstraint.activate([
			leftScrollView.topAnchor.constraint(equalTo: topScrollView.bottomAnchor),
			leftScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			leftScrollView.leftAnchor.constraint(equalTo: leftAnchor),
			leftScrollViewWidth,

			topScrollView.topAnchor.constraint(equalTo: topAnchor),
			topScrollView.leftAnchor.constraint(equalTo: leftScrollView.rightAnchor),
			topScrollView.rightAnchor.constraint(equalTo: rightAnchor),
			topScrollViewHeight,

			contentScrollView.topAnchor.constraint(equalTo: topScrollView.bottomAnchor),
			contentScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			contentScrollView.rightAnchor.constraint(equalTo: rightAnchor),
			contentScrollView.leftAnchor.constraint(equalTo: leftScrollView.rightAnchor),
		])
	}
}

// MARK: - Reloads
extension SheetView {
	public func reloadData() {
		reloadContentColumns()
		reloadContentRows()
		reloadFixedTopRows()
		reloadFixedLeftColumns()

		topScrollView.columns = columns
		topScrollView.rows = fixedTopRows
		leftScrollView.columns = fixedLeftColumns
		leftScrollView.rows = rows
		contentScrollView.columns = columns
		contentScrollView.rows = rows

		syncContentOffsets = false
		topScrollView.reloadData()
		leftScrollView.reloadData()
		contentScrollView.reloadData()
		syncContentOffsets = true
	}

	public func reloadCellAt(index: SheetIndex) {
		contentScrollView.reloadCellsAt(indices: [index])
	}

	public func reloadCellsAt(indices: [SheetIndex]) {
		contentScrollView.reloadCellsAt(indices: indices)
	}

	private func reloadContentColumns() {
		let columnCount = dataSource?.sheetNumberOfColumns(self) ?? 0
		columns.removeAll(keepingCapacity: true)
		if columnCount > 0 {
			columns.reserveCapacity(columnCount)
			var offset = 0.0
			for i in 0..<columnCount {
				let width = dataSource?.sheetColumnWidth(self, at: i) ?? Self.defaultColWidth
				columns.append(.init(index: i, width: width, offset: offset))
				offset += width
			}
		}
	}

	private func reloadContentRows() {
		let rowCount = dataSource?.sheetNumberOfRows(self) ?? 0
		rows.removeAll(keepingCapacity: true)
		if rowCount > 0 {
			rows.reserveCapacity(rowCount)
			var offset = 0.0
			for i in 0..<rowCount {
				let height = dataSource?.sheetRowHeight(self, at: i) ?? Self.defaultRowHeight
				rows.append(.init(index: i, height: height, offset: offset))
				offset += height
			}
		}
	}

	private func reloadFixedTopRows() {
		let count = dataSource?.sheetNumberOfFixedRows(self, in: .fixedTop) ?? 0
		fixedTopRows.removeAll(keepingCapacity: true)
		if count > 0 {
			fixedTopRows.reserveCapacity(count)
			var offset = 0.0
			for i in 0..<count {
				let height = dataSource?.sheet(self, heightForFixedRowAt: i, in: .fixedTop) ?? Self.defaultRowHeight
				fixedTopRows.append(.init(index: i, height: height, offset: offset))
				offset += height
			}
			topScrollViewHeight.constant = offset
		} else {
			topScrollViewHeight.constant = 0.0
		}
	}

	private func reloadFixedLeftColumns() {
		let count = dataSource?.sheetNumberOfFixedColumns(self, in: .fixedLeft) ?? 0
		fixedLeftColumns.removeAll(keepingCapacity: true)
		if count > 0 {
			fixedLeftColumns.reserveCapacity(count)
			var offset = 0.0
			for i in 0..<count {
				let width = dataSource?.sheet(self, heightForFixedRowAt: i, in: .fixedLeft) ?? Self.defaultColWidth
				fixedLeftColumns.append(.init(index: i, width: width, offset: offset))
				offset += width
			}
			leftScrollViewWidth.constant = offset
		} else {
			leftScrollViewWidth.constant = 0.0
		}
	}
}

// MARK: - Cell Lifecycle
extension SheetView {

	public func register(_ type: SheetViewCell.Type, forCellReuseIdentifier id: String) {
		guard cellQueues[id] == nil else {
			fatalError("\(id) is already registered in \(self)")
		}
		let clientLimit = dataSource?.sheet(self, queueLimitForReuseIdentifier: id) ?? -1
		let limit = clientLimit > -1
		? clientLimit
		: max(Int(bounds.width / Self.defaultColWidth), Self.minQueueLimit)
		cellQueues[id] = .init(id: id, limit: limit, type: type)
	}

	public func dequeueReusableCell(withIdentifier reuseIdentifier: String) -> SheetViewCell {
		guard let queue = cellQueues[reuseIdentifier] else {
			fatalError("\(reuseIdentifier) was not registered for reuse.")
		}

		let cell = queue.dequeue()
		cell.prepareForReuse()
		return cell
	}

	func cellFor(_ index: SheetIndex, in area: SheetViewArea) -> SheetViewCell {
		switch area {
		case .unknown:
			fatalError("\(self) can't produce a cell for an unknown area")
		case .content:
			let cell = dataSource?.sheet(self, cellFor: index) ?? SheetViewCell(index: index)
			if selection.contains(index) {
				cell.selection = selection
			} else {
				cell.selection = .none
			}
			cell.sheetIndex = index
			return cell
		case .fixedTop:
			let cell = dataSource?.sheet(self, cellForFixedRowAt: index, in: area)
			?? SheetViewCell(index: index)
			if case .columnSet(_) = selection, selection.contains(index) {
				cell.selection = selection
			} else if case .columnRange(_, _) = selection, selection.contains(index) {
				cell.selection = selection
			} else {
				cell.selection = .none
			}
			cell.sheetIndex = index
			return cell
		case .fixedLeft:
			let cell = dataSource?.sheet(self, cellForFixedColumnAt: index, in: area)
			?? SheetViewCell(index: index)
			if case .row(_) = selection, selection.contains(index) {
				cell.selection = selection
			} else {
				cell.selection = .none
			}
			cell.sheetIndex = index
			return cell
		}
	}

	func releaseCell(_ cell: SheetViewCell) {
		cell.sheetIndex = .invalid
		cell.selection = .none
		cell.removeFromSuperview()

		guard let queue = cellQueues[cell.reuseIdentifier] else {
			return
		}

		queue.enqueue(cell)
	}
}

// MARK: - Cell Editing
extension SheetView {
	func shouldEditCell(at index: SheetIndex) -> Bool {
		return delegate?.sheet(self, shouldEditCellAt: index) ?? false
	}

	func editorViewFor(index: SheetIndex) -> UIView {
		return dataSource?.sheet(self, editorCellFor: index) ?? UIView()
	}

	func endCellEditing(at index: SheetIndex, andRelease editor: UIView) {
		delegate?.sheet(self, didEndEditingCellAt: index, with: editor)
		editor.removeFromSuperview()
	}
}

// MARK: - UIScrollViewDelegate
extension SheetView: UIScrollViewDelegate {
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard syncContentOffsets else {
			return
		}
		let offset = scrollView.contentOffset
		if scrollView == contentScrollView {
			topScrollView.contentOffset.x = offset.x
			leftScrollView.contentOffset.y = offset.y
			return
		}

		if scrollView == topScrollView {
			contentScrollView.contentOffset.x = offset.x
			return
		}

		if scrollView == leftScrollView {
			contentScrollView.contentOffset.y = offset.y
			return
		}
	}
}
