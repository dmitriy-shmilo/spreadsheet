//

import UIKit

struct SheetColumnDefinition {
	var index: Int = -1
	var width: CGFloat = 0.0
	var offset: CGFloat = 0.0
}

@IBDesignable
public class SheetView: UIView {
	static let defaultColWidth: CGFloat = 100.0
	static let defaultRowHeight: CGFloat = 45.0

	public weak var dataSource: SheetDataSource? {
		didSet {
			refreshContentMeasurements()
		}
	}

	public weak var delegate: SheetViewDelegate?
	internal(set) public var selection = SheetSelection.none {
		didSet {
			delegate?.sheet(
				self,
				didChangeSelection: selection,
				from: oldValue)
		}
	}

	public var allowedSelectionModes = SheetSelectionMode.all

	var columns = [SheetColumnDefinition]()

	private var scrollView: SheetScrollView!

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
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

	func cellFor(_ index: SheetIndex) -> SheetViewCell {
		guard let cell = dataSource?.sheet(self, cellFor: index) else {
			return SheetViewCell(index: index)
		}
		cell.sheetIndex = index
		return cell
	}

	func freeCell(_ cell: SheetViewCell) {
		// TODO: enqueue for reuse
		cell.sheetIndex = .invalid
		cell.removeFromSuperview()
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

		scrollView.estRowHeight = dataSource?.sheetRowHeight(self) ?? Self.defaultRowHeight
		scrollView.rowCount = dataSource?.sheetNumberOfRows(self) ?? 0
		scrollView.refreshContentMeasurements()
	}
}


