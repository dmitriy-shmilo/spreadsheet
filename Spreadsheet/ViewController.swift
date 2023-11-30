//

import UIKit

class ViewController: UIViewController {
	@IBOutlet private weak var sheet: SheetView!

	override func viewDidLoad() {
		super.viewDidLoad()
		sheet.dataSource = self
	}
}

extension ViewController: SheetDataSource {
	func sheetRowHeight(_ sheet: SheetView) -> CGFloat {
		return 30.0
	}

	func sheetColumnWidth(_ sheet: SheetView) -> CGFloat {
		return 300.0
	}

	func sheetNumberOfColumns(_ sheet: SheetView) -> Int {
		return 100
	}

	func sheetNumberOfRows(_ sheet: SheetView) -> Int {
		return 1000
	}

	func sheet(_ sheet: SheetView, cellFor index: SheetIndex) -> UIView {
		let view = UILabel()
		view.layer.borderWidth = 1.0
		view.layer.borderColor = .init(gray: 0.5, alpha: 0.5)
		view.backgroundColor = .white
		view.textColor = .black
		view.text = "\(index)"
		return view
	}
}
