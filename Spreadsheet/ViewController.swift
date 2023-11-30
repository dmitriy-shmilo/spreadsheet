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
	func SheetRowHeight(_ sheet: SheetView) -> CGFloat {
		return 30.0
	}

	func SheetColumnWidth(_ sheet: SheetView) -> CGFloat {
		return 300.0
	}

	func SheetNumberOfColumns(_ sheet: SheetView) -> Int {
		return 100
	}

	func SheetNumberOfRows(_ sheet: SheetView) -> Int {
		return 1000
	}

	func Sheet(_ sheet: SheetView, cellFor index: SheetIndex) -> UIView {
		let view = UILabel()
		view.layer.borderWidth = 1.0
		view.layer.borderColor = .init(gray: 0.5, alpha: 0.5)
		view.backgroundColor = .white
		view.textColor = .black
		view.text = "\(index)"
		return view
	}
}
