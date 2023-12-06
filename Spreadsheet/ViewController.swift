//

import UIKit

class ViewController: UIViewController {
	@IBOutlet private weak var sheet: SheetView!

	let columnCount = 20
	let rowCount = 50

	var data = [String]()

	override func viewDidLoad() {
		super.viewDidLoad()


		for y in 0..<rowCount {
			for x in 0..<columnCount {
			data.append("Col: \(x), Row: \(y)")
			}
		}

		sheet.register(SheetViewTextCell.self, forCellReuseIdentifier: "cell")
		sheet.dataSource = self
		sheet.delegate = self
		sheet.reloadData()
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
		return columnCount
	}

	func sheetNumberOfRows(_ sheet: SheetView) -> Int {
		return rowCount
	}

	func sheet(_ sheet: SheetView, cellFor index: SheetIndex) -> SheetViewCell {
		guard let cell = sheet.dequeueReusableCell(withIdentifier: "cell") as? SheetViewTextCell else {
			return .init()
		}
		let datum = data[index.index]

		cell.label.text = datum
		cell.label.font = .systemFont(ofSize: 16.0)
		cell.label.textColor = .secondaryLabel
		cell.normalBackgroundColor = .systemBackground
		cell.selectedBackgroundColor = .systemBlue.withAlphaComponent(0.3)
		if sheet.selection.contains(index) {
			cell.selection = sheet.selection
		}
		return cell
	}

	func sheet(_ sheet: SheetView, didEndEditingCellAt index: SheetIndex, with editor: UIView) {
		data[index.index] = (editor as? UITextView)?.text ?? ""
		sheet.reloadCellAt(index: index)
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

	func sheet(_ sheet: SheetView, editorCellFor index: SheetIndex) -> UIView? {
		let datum = data[index.index]
		let cell = UITextView()
		cell.text = datum
		cell.isEditable = true
		cell.layer.borderColor = UIColor.systemBlue.cgColor
		cell.backgroundColor = .tertiarySystemBackground
		cell.textColor = .label
		cell.font = .systemFont(ofSize: 16.0)
		return cell
	}

	func sheet(_ sheet: SheetView, shouldEditCellAt index: SheetIndex) -> Bool {
		return index.row % 3 != 0
	}
}

extension ViewController: SheetViewDelegate {
	
}
