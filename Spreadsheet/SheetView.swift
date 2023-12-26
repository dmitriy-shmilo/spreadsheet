//

import UIKit

/// A spreadsheet-like view, designed to display two dimensional tables
/// of cells with predetermined widths and heights. After instantiating, assign the ``dataSource``
/// property in order to provide the necessary dimensions and cell subviews.
/// Call ``reloadData()`` afterwards. Optionally, assign  a ``delegate`` for further fine
/// tune the behavior.
///
/// Internally, this view contains multiple synchronized scrollviews, one for each ``SheetViewArea``.
/// When scrolled, each area will request a set of, potentially reusable, cells from the datasource and place
/// each cell inside of itself. Cells, which are no longer visible, will be discarded to save the resources.
public class SheetView: UIView {
	static let minQueueLimit = 100
	static let defaultColWidth: CGFloat = 100.0
	static let defaultRowHeight: CGFloat = 45.0

	/// Gets or sets the ``SheetViewDataSource`` implementation for this view. If nil, no data
	/// will be visible in the sheet by default. After assigning a datasource, call ``reloadData()``.
	public weak var dataSource: SheetViewDataSource?

	/// Gets or sets the ``SheetViewDelegate`` implementation for this view. Delegate methods
	/// will be called when the user interacts with the table.
	public weak var delegate: SheetViewDelegate?

	/// Gets or sets the ``SheetViewResizingDelegate`` implementation for this view. If not
	/// provided, resizing methods like ``beginResizingColumn(at:)`` won't have any meaningful
	/// effect.
	public weak var resizingDelegate: SheetViewResizingDelegate?

	/// Gets the current ``SheetSelection``, ``SheetSelection/none`` by default.
	/// Current selection will be passed to each visible ``SheetViewCell``, which might affect
	/// their presentation. Use ``setSelection(_:)`` in order to change the current selection.
	private(set) public var currentSelection = SheetSelection.none

	/// Gets or sets current allowed selection mode. Defaults to
	/// ``SheetViewSelectionMode/all``. Only affects the default implementation of
	/// ``SheetViewDelegate`` methods.
	public var allowedSelectionModes = SheetViewSelectionMode.all

	/// Gets whether this sheet view is in the process of resizing a column. Returns true if
	/// ``beginResizingColumn(at:)`` was called. Is set to false after ``endResizingColumn()``
	/// was executed.
	public var isResizing: Bool {
		get {
			return resizedColumnIndex != SheetIndex.invalid.col
		}
	}

	/// Gets column inex of the currently resized column. Set by ``beginResizingColumn(at:)``.
	/// Is invalid when not resizing a column.
	private(set) public var resizedColumnIndex = SheetIndex.invalid.col

	/// Gets the column width of the currently resized column. Set by ``updateResizingColumn(at:to:)``.
	/// Is invalid when not resizing a column.
	private(set) public var resizedColumnWidth: CGFloat = 0.0

	var columns = [SheetViewColumnDefinition]()
	var rows = [SheetViewRowDefinition]()
	var fixedTopRows = [SheetViewRowDefinition]()
	var fixedLeftColumns = [SheetViewColumnDefinition]()

	private var topScrollView: SheetFixedHorizontalScrollView!
	private var topScrollViewHeight: NSLayoutConstraint!
	private var leftScrollView: SheetFixedVerticalScrollView!
	private var leftScrollViewWidth: NSLayoutConstraint!
	private var contentScrollView: SheetContentScrollView!
	private var syncContentOffsets = true

	private let defaultResizerView = UIView()
	private var currentResizerView: UIView?

	private var cellQueues = [String: SheetViewCellQueue]()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override public var bounds: CGRect {
		didSet {
			guard bounds != oldValue else {
				return
			}

			updateResizingColumn(at: resizedColumnIndex, to: resizedColumnWidth)
		}
	}

	/// Creates a ``SheetIndex`` instance with given column and row reference within
	/// this spreadsheet.
	public func makeIndex(_ col: Int, _ row: Int) -> SheetIndex {
		return .init(col: col, row: row, index: row * columns.count + col)
	}

	// MARK: - Selection
	/// Call this method to change the ``currentSelection`` value. If changed to a new value,
	/// each area selection will be cleared, and all visible cells, will get assigned an appropriate
	/// ``SheetViewCell/selection`` value.
	///
	/// ``SheetViewArea/fixedTop`` area cells can only be selected with a
	/// column selection variant.
	///
	/// ``SheetViewArea/fixedLeft`` area cells can only be selected with a
	/// row selection variant.
	///
	/// Visible cells in the ``SheetViewArea/content`` area can be assigned all possible
	/// selection variants.
	public func setSelection(_ selection: SheetSelection) {
		guard currentSelection != selection else {
			return
		}

		for scrollView in [topScrollView, leftScrollView] {
			if scrollView!.isSelectionSupported(selection) {
				scrollView!.setSelection(selection)
				continue
			}
			scrollView!.clearSelection()
		}
		contentScrollView.setSelection(selection)

		delegate?.sheet(self, didChangeSelection: selection, from: currentSelection)
		currentSelection = selection
	}

	/// Scroll the ``SheetViewArea/content`` area so that the cells in the `selection`
	/// are visible. If the selection is already fully visible, doesn't do anything.
	///
	/// If scrolling to row or
	/// column selection variants, only vertical or horizontal (respectively) scrolling will occur.
	///
	/// If scrolling to a cell range or set, will attempt to make the selection bounding rectangle visible.
	/// If the bounding rectangle doesn't fit into the view, the top left corner will be guaranteed to be
	/// visible.
	///
	/// Other areas will syncronize their offsets as the content area scrolls.
	///
	/// - Parameter animated: whether to animate the scrolling. Passing `true` might result in
	/// a considetable amount of cells being requested and dismissed in quick succession.
	public func scrollToSelection(_ selection: SheetSelection, animated: Bool) {
		contentScrollView.scrollToSelection(selection, animated: animated)
	}

	/// Same as calling ``scrollToSelection(_:animated:)`` with
	/// ``currentSelection``.
	public func scrollToCurrentSelection(animated: Bool) {
		contentScrollView.scrollToSelection(currentSelection, animated: animated)
	}

	// MARK: - Sizing
	/// Gets a `UIView` `frame`, which a cell with the given index is expected to have when placed
	/// within ``SheetViewArea/content``.
	///
	/// Returns a zero frame for invalid indices.
	public func frameRectFor(index: SheetIndex) -> CGRect {
		guard isValid(index: index) else {
			return .zero
		}

		return .init(
			x: columns[index.col].offset,
			y: rows[index.row].offset,
			width: columns[index.col].width,
			height: rows[index.row].height)
	}

	/// Resizes a column with given index to a given width. Affects both the content and fixed areas.
	/// All column offsets to the right of the affected one will be recalculated. If there is an intersection
	/// between the affected column range with the currently visible columns, then visible cells will be
	/// reloaded, and their frames updated.
	///
	/// Doesn't do anything if the index is invalid. Doesn't do anything if the width is not changed.
	///
	/// > Affected cell reloads may be optimized in the future. Do not rely on cell reloads after calling
	/// > this method.
	///
	/// > Setting individual column widths is expensive. Consider reloading the table if there's a need
	/// > to update multiple column widths.
	public func setWidth(_ width: CGFloat, for index: Int) {
		guard index >= 0 && index < columns.count else {
			return
		}

		guard width != columns[index].width else {
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

		syncContentOffsets = false
		defer {
			syncContentOffsets = true
		}
		if range.rightColumn > index {
			let contentRange = SheetCellRange(
				leftColumn: index,
				rightColumn: range.rightColumn,
				topRow: range.topRow,
				bottomRow: range.bottomRow)

			contentScrollView.layoutVisibleCells(in: contentRange)
			contentScrollView.invalidateContentSize()
			contentScrollView.releaseCells(outside: contentScrollView.visibleRange)
			contentScrollView.addCells(in: contentScrollView.visibleRange)

			let topRange = SheetCellRange(
				leftColumn: index,
				rightColumn: range.rightColumn,
				topRow: 0,
				bottomRow: fixedTopRows.count)
			topScrollView.layoutVisibleCells(in: topRange)
			topScrollView.invalidateContentSize()
			topScrollView.releaseCells(outside: topScrollView.visibleRange)
			topScrollView.addCells(in: topScrollView.visibleRange)
		} else {
			contentScrollView.invalidateContentSize()
			topScrollView.invalidateContentSize()
		}
	}

	// MARK: - Editing
	/// Attempts to start editing a cell at a given index. An editor view will be requested
	/// from the ``delegate``, and then placed over the currently edited cell. Call
	/// ``endEditCell()`` to dismiss the editor.
	///
	/// > If an editing already began, calling this method the second time will end the previous editing.
	///
	/// > If called for an invalid index, nothing will happen.
	public func editCellAt(_ index: SheetIndex) {
		guard isValid(index: index) else {
			return
		}
		contentScrollView.endEditCell()
		contentScrollView.beginEditCell(at: index)
	}

	/// Dismiss the current cell editor, which was previously spawned by a ``editCellAt(_:)`` call.
	/// After dismissal,
	/// ``SheetViewDelegate/sheet(_:didEndEditingCellAt:with:)-2sxsz`` will
	/// be called.
	///
	/// > If there's no current editor, nothing will happen.
	public func endEditCell() {
		contentScrollView.endEditCell()
	}

	// MARK: - Private Methods
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

		defaultResizerView.frame = .zero
		defaultResizerView.isUserInteractionEnabled = false
		defaultResizerView.backgroundColor = .systemBlue
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

	/// Creates an internal cell reuse queue with a given identifier for a ``SheetViewCell`` subclass.
	/// Discarded cells will be placed on this queue, and can later be recycled.
	/// Make sure to register all identifiers before making calls to
	/// ``dequeueReusableCell(withIdentifier:)``.
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

	/// Attempts to recycle a dismissed cell, which was placed on a reusable cell queue. If there's
	/// no reusable cells on the queue at the moment, a new one will be instantiated. In either case,
	/// ``SheetViewCell/prepareForReuse()`` will be called, which should be used to reset
	/// the cell state.
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
			cell.sheetIndex = index
			if currentSelection.contains(index) {
				cell.selection = currentSelection
			} else {
				cell.selection = .none
			}
			return cell
		case .fixedTop:
			let cell = dataSource?.sheet(self, cellForFixedRowAt: index, in: area)
			?? SheetViewCell(index: index)
			cell.sheetIndex = index
			if case .columnSet(_) = currentSelection, currentSelection.contains(index) {
				cell.selection = currentSelection
			} else if case .columnRange(_, _) = currentSelection, currentSelection.contains(index) {
				cell.selection = currentSelection
			} else {
				cell.selection = .none
			}
			return cell
		case .fixedLeft:
			let cell = dataSource?.sheet(self, cellForFixedColumnAt: index, in: area)
			?? SheetViewCell(index: index)
			cell.sheetIndex = index
			if case .rowSet(_) = currentSelection, currentSelection.contains(index) {
				cell.selection = currentSelection
			} else if case .rowRange(_, _) = currentSelection, currentSelection.contains(index) {
				cell.selection = currentSelection
			} else {
				cell.selection = .none
			}
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
	func editorViewFor(index: SheetIndex) -> UIView {
		return dataSource?.sheet(self, editorCellFor: index) ?? UIView()
	}

	func endCellEditing(at index: SheetIndex, andRelease editor: UIView) {
		delegate?.sheet(self, didEndEditingCellAt: index, with: editor)
		editor.removeFromSuperview()
	}
}

// MARK: - Resizing
extension SheetView {

	/// Starts resizing a column at a given index. If another column was being resized already, the previous resizing will end first.
	/// When called, will spawn a resizer view, whose location depends on the resized column offset.
	/// Use ``updateResizingColumn(at:to:)`` to move the resizer view.
	/// Call ``endResizingColumn()`` to stop the resizing.
	public func beginResizingColumn(at index: Int) {
		guard isValid(column: index) else {
			return
		}

		endResizingColumn()

		let column = columns[index]
		let offset = column.offset + column.width
		let resizerOffset = contentScrollView.convert(.init(x: offset, y: 0), to: self).x
		resizedColumnIndex = index
		resizedColumnWidth = column.width

		let resizer = resizingDelegate?.sheet(
			self,
			resizerViewForColumnAt: index)
		?? defaultResizerView

		resizer.frame = resizingDelegate?.sheet(
			self,
			resizerFrameForColumnAt: resizerOffset)
		?? .init(x: resizerOffset, y: 0, width: 1.0, height: frame.height)

		addSubview(resizer)
		currentResizerView = resizer
	}

	/// Call this method after ``beginResizingColumn(at:)`` to move the resizer indicator so that it indicates
	/// a desired `width` of the column. This method does nothing if `index` doesn't match the
	/// ``resizedColumnIndex`` or  if `width` is invalid. Call ``endResizingColumn()``
	/// to finilize the change.
	public func updateResizingColumn(at index: Int, to width: CGFloat) {
		guard index == resizedColumnIndex && index != SheetIndex.invalid.col else {
			return
		}

		guard width > 0.0 else {
			return
		}

		guard let resizer = currentResizerView else {
			return
		}

		let column = columns[index]
		let offset = column.offset + width
		let resizerOffset = contentScrollView.convert(.init(x: offset, y: 0), to: self).x
		resizer.frame = resizingDelegate?.sheet(
			self,
			resizerFrameForColumnAt: resizerOffset)
		?? .init(x: resizerOffset, y: 0, width: 1.0, height: frame.height)
	}

	/// Finilizes the column resizing relaying the current ``resizedColumnIndex`` and ``resizedColumnWidth``
	/// to ``SheetViewDelegate/sheet(_:didEndResizingColumnAt:to:)-6skv5`` and resetting
	/// the resizing state. Doesn't do anything if resizing wasn't started with ``beginResizingColumn(at:)``.
	public func endResizingColumn() {
		guard resizedColumnIndex != SheetIndex.invalid.col else {
			return
		}
		resizingDelegate?.sheet(self, didEndResizingColumnAt: resizedColumnIndex, to: resizedColumnWidth)
		resizedColumnIndex = SheetIndex.invalid.col
		resizedColumnWidth = 0.0
		currentResizerView?.removeFromSuperview()
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
			updateResizingColumn(at: resizedColumnIndex, to: resizedColumnWidth)
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

// MARK: - Misc
extension SheetView {
	/// Returns true if the given index can exist within this spreadsheet.
	public func isValid(index: SheetIndex) -> Bool {
		return index.row >= 0
		&& index.row < rows.count
		&& index.col >= 0
		&& index.col < columns.count
		&& index.index == index.col + index.row * columns.count
	}

	/// Returns true if the given column index can exist within this spreadsheet.
	public func isValid(column: Int) -> Bool {
		return column >= 0 && column < columns.count
	}

	/// Returns true if the given row  index can exist within this spreadsheet.
	public func isValid(row: Int) -> Bool {
		return row >= 0 && row < rows.count
	}
}
