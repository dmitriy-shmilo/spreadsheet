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
	func sheetColumnWidth(_ sheet: SheetView, at index: Int) -> CGFloat {
		return 100.0 + CGFloat(index % 3) * 150.0
	}

	func sheetNumberOfColumns(_ sheet: SheetView) -> Int {
		return 100
	}

	func sheetNumberOfRows(_ sheet: SheetView) -> Int {
		return 1000
	}

	func sheet(_ sheet: SheetView, cellFor index: SheetIndex) -> SheetViewCell {
		let cell = SheetViewTextCell()
		cell.label.text = "\(index)"
		return cell
	}
}
