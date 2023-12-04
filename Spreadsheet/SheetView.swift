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

enum SheetViewArea {
	case unknown
	case content
	case fixedTop
}

@IBDesignable
public class SheetView: UIView {
	static let minQueueLimit = 100
	static let defaultColWidth: CGFloat = 100.0
	static let defaultRowHeight: CGFloat = 45.0

	public weak var dataSource: SheetDataSource? {
		didSet {
			refreshContentMeasurements()
		}
	}

	public weak var delegate: SheetViewDelegate?
	public var selection: SheetSelection {
		get {
			return scrollView.selection
		}
	}

	public var allowedSelectionModes = SheetSelectionMode.all

	var columns = [SheetColumnDefinition]()
	var rows = [SheetRowDefinition]()
	var fixedTopRows = [SheetRowDefinition]()

	private var topScrollView: SheetFixedRowScrollView!
	private var topScrollViewHeight: NSLayoutConstraint!
	// TODO: rename to contentScrollView
	private var scrollView: SheetScrollView!

	private var cellQueues = [String: SheetViewCellQueue]()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	public func setSelection(_ selection: SheetSelection, animated: Bool) {
		scrollView.setSelection(selection, animated: animated)
	}

	public func makeIndex(_ col: Int, _ row: Int) -> SheetIndex {
		return .init(col: col, row: row, index: row * columns.count + col)
	}

	public func reloadCellsAt(index: SheetIndex) {
		scrollView.reloadCellsAt(indices: [index])
	}

	public func reloadCellsAt(indices: [SheetIndex]) {
		scrollView.reloadCellsAt(indices: indices)
	}

	private func setup() {
		topScrollView = .init(frame: .zero)
		topScrollView.translatesAutoresizingMaskIntoConstraints = false
		topScrollView.sheet = self
		topScrollView.delegate = self
		topScrollView.showsVerticalScrollIndicator = false
		topScrollView.showsHorizontalScrollIndicator = false
		topScrollViewHeight = topScrollView.heightAnchor.constraint(equalToConstant: 0.0)
		addSubview(topScrollView)

		scrollView = .init(frame: .zero)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.sheet = self
		scrollView.delegate = self
		addSubview(scrollView)

		NSLayoutConstraint.activate([
			topScrollView.topAnchor.constraint(equalTo: topAnchor),
			topScrollView.leftAnchor.constraint(equalTo: leftAnchor),
			topScrollView.rightAnchor.constraint(equalTo: rightAnchor),
			topScrollViewHeight,

			scrollView.topAnchor.constraint(equalTo: topScrollView.bottomAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			scrollView.rightAnchor.constraint(equalTo: rightAnchor),
			scrollView.leftAnchor.constraint(equalTo: leftAnchor),
		])
		refreshContentMeasurements()
	}

	private func refreshContentMeasurements() {
		reloadContentColumns()
		reloadContentRows()
		reloadFixedTopRows()

		topScrollView.refreshContentMeasurements()
		scrollView.refreshContentMeasurements()
	}

	private func reloadContentColumns() {
		let columnCount = dataSource?.sheetNumberOfColumns(self) ?? 0
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
		let fixedTopRowCount = dataSource?.sheetNumberOfFixedTopRows(self) ?? 0
		if fixedTopRowCount > 0 {
			fixedTopRows.reserveCapacity(fixedTopRowCount)
			var offset = 0.0
			for i in 0..<fixedTopRowCount {
				let height = dataSource?.sheet(self, heightForFixedTopRowAt: i) ?? Self.defaultRowHeight
				fixedTopRows.append(.init(index: i, height: height, offset: offset))
				offset += height
			}
			topScrollViewHeight.constant = fixedTopRows.last!.offset + fixedTopRows.last!.height
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

		return queue.dequeue()
	}

	func cellFor(_ index: SheetIndex, in area: SheetViewArea) -> SheetViewCell {
		switch area {
		case .unknown:
			fatalError("\(self) can't produce a cell for an unknown area")
		case .content:
			let cell = dataSource?.sheet(self, cellFor: index) ?? SheetViewCell(index: index)
			if selection.contains(index) {
				cell.selection = selection
			}
			cell.sheetIndex = index
			return cell
		case .fixedTop:
			let cell = dataSource?.sheet(self, cellFor: index.col, inFixedTopRow: index.row)
			?? SheetViewCell(index: index)
			if case .column(_) = selection, selection.contains(index) {
				cell.selection = selection
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

extension SheetView: UIScrollViewDelegate {
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offset = scrollView.contentOffset
		if scrollView == self.scrollView {
			topScrollView.contentOffset.x = offset.x
			return
		}

		if scrollView == topScrollView {
			self.scrollView.contentOffset.x = offset.x
			return
		}
	}
}
