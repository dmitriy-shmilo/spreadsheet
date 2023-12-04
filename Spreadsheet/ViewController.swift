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

	func sheetRowHeight(_ sheet: SheetView, at index: Int) -> CGFloat {
		return 100.0 + CGFloat(index % 4) * 50.0
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
		cell.label.numberOfLines = 0
		cell.label.text = "\(index)"
		cell.label.font = .systemFont(ofSize: 16.0)
		cell.label.textColor = .secondaryLabel
		cell.normalBackgroundColor = .systemBackground
		cell.selectedBackgroundColor = .systemBlue.withAlphaComponent(0.3)
		if sheet.selection.contains(index) {
			cell.selection = sheet.selection
		}
		return cell
	}

	func sheet(_ sheet: SheetView, didChangeSelection to: SheetSelection, from: SheetSelection) {
		sheet.setSelection(.range(left: 20, top: 0, right: 22, bottom: 100), animated: true)
	}

	func sheetNumberOfFixedTopRows(_ sheet: SheetView) -> Int {
		return 2
	}

	func sheet(_ sheet: SheetView, cellFor column: Int, inFixedTopRow row: Int) -> SheetViewCell {
		guard let cell = sheet.dequeueReusableCell(withIdentifier: "cell") as? SheetViewTextCell else {
			return .init()
		}

		if row == 0 {
			cell.label.text = "Header: \(column)"
			cell.label.font = .boldSystemFont(ofSize: 16.0)
			cell.label.textColor = .secondaryLabel
			cell.normalBackgroundColor = .secondarySystemBackground
		} else {
			cell.label.text = "Subeader: \(column)"
			cell.label.textColor = .tertiaryLabel
			cell.label.font = .boldSystemFont(ofSize: 14.0)
			cell.normalBackgroundColor = .tertiarySystemBackground
		}

		return cell
	}
}

extension ViewController: SheetViewDelegate {
	
}
