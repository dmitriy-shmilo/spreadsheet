//

import UIKit

@IBDesignable
public class SheetView: UIView {
	private static let defaultColWidth: CGFloat = 100.0
	private static let defaultRowHeight: CGFloat = 30.0

	public weak var dataSource: SheetDataSource? {
		didSet {
			refreshContentMeasurements()
		}
	}

	private var scrollView: SheetScrollView!

	private var estColWidth: CGFloat = defaultColWidth
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

	func cellFor(_ index: SheetIndex) -> UIView {
		guard let cell = dataSource?.sheet(self, cellFor: index) else {
			// TODO: default cell implementation
			return UIView()
		}
		return cell
	}

	func freeCell(_ cell: UIView) {
		// TODO: enqueue for reuse
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
		estColWidth = dataSource?.sheetColumnWidth(self) ?? Self.defaultColWidth
		estRowHeight = dataSource?.sheetRowHeight(self) ?? Self.defaultRowHeight
		colCount = dataSource?.sheetNumberOfColumns(self) ?? 0
		rowCount = dataSource?.sheetNumberOfRows(self) ?? 0

		scrollView.estColWidth = estColWidth
		scrollView.estRowHeight = estRowHeight
		scrollView.colCount = colCount
		scrollView.rowCount = rowCount
		scrollView.refreshContentMeasurements()
	}
}


