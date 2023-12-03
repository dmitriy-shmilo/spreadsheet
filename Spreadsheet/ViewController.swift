//

import UIKit

class ViewController: UIViewController {
	@IBOutlet private weak var sheet: SheetView!

	override func viewDidLoad() {
		super.viewDidLoad()
		sheet.register(SheetViewTextCell.self, forCellReuseIdentifier: "cell")
		sheet.dataSource = self
		sheet.delegate = self
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
		guard let cell = sheet.dequeueReusableCell(withIdentifier: "cell") as? SheetViewTextCell else {
			return .init()
		}
		cell.label.text = "\(index)"
		cell.selectedBackgroundColor = .systemBlue.withAlphaComponent(0.3)
		if sheet.selection.contains(index) {
			cell.selection = sheet.selection
		}
		return cell
	}
}

extension ViewController: SheetViewDelegate {
	
}
