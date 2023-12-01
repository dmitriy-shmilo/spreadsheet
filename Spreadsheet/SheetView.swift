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

	var columns = [SheetColumnDefinition]()

	private var scrollView: SheetScrollView!
	private var estRowHeight: CGFloat = defaultRowHeight
	private var colCount = 0
	private var rowCount = 0

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
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

		estRowHeight = dataSource?.sheetRowHeight(self) ?? Self.defaultRowHeight
		colCount = dataSource?.sheetNumberOfColumns(self) ?? 0
		rowCount = dataSource?.sheetNumberOfRows(self) ?? 0

		scrollView.estRowHeight = estRowHeight
		scrollView.rowCount = rowCount
		scrollView.refreshContentMeasurements()
	}
}


