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
		scrollView = .init(frame: frame)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.sheet = self
		addSubview(scrollView)
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			scrollView.rightAnchor.constraint(equalTo: rightAnchor),
			scrollView.leftAnchor.constraint(equalTo: leftAnchor),
		])
		refreshContentMeasurements()
	}

	private func refreshContentMeasurements() {
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
		scrollView.refreshContentMeasurements()
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

	func cellFor(_ index: SheetIndex) -> SheetViewCell {
		guard let cell = dataSource?.sheet(self, cellFor: index) else {
			return SheetViewCell(index: index)
		}
		if selection.contains(index) {
			cell.selection = selection
		}
		cell.sheetIndex = index
		return cell
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
