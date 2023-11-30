//

import UIKit

class ViewController: UIViewController {
	@IBOutlet private weak var sheet: SpreadsheetView!

	override func viewDidLoad() {
		super.viewDidLoad()
		sheet.dataSource = self
	}
}

extension ViewController: SpreadsheetDataSource {
	func spreadsheetRowHeight(_ sheet: SpreadsheetView) -> CGFloat {
		return 30.0
	}

	func spreadsheetColumnWidth(_ sheet: SpreadsheetView) -> CGFloat {
		return 300.0
	}

	func spreadsheetNumberOfColumns(_ sheet: SpreadsheetView) -> Int {
		return 100
	}

	func spreadsheetNumberOfRows(_ sheet: SpreadsheetView) -> Int {
		return 1000
	}

	func spreadsheet(_ sheet: SpreadsheetView, cellFor index: SpreadsheetIndex) -> UIView {
		let view = UILabel()
		view.layer.borderWidth = 1.0
		view.layer.borderColor = .init(gray: 0.5, alpha: 0.5)
		view.backgroundColor = .white
		view.textColor = .black
		view.text = "\(index)"
		return view
	}
}
