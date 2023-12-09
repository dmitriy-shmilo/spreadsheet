//

import UIKit

class SheetContentScrollView: SheetScrollView {
	private var isEditing = false
	private var editorIndex = SheetIndex.invalid
	private var editorView: UIView?

	override var selection: SheetSelection {
		didSet {
			if oldValue != selection {
				sheet.delegate?.sheet(
					sheet,
					didChangeSelection: selection,
					from: oldValue)
			}
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}

		guard sheet.allowedSelectionModes.contains(.cell) else {
			return
		}

		let point = touch.location(in: self)
		guard let colIndex = findVisibleColumnIntersecting(
			offset: point.x)?.index else {
			return
		}

		guard let rowIndex = findVisibleRowIntersecting(offset: point.y)?.index else {
			return
		}
		let cellIndex = sheet.makeIndex(colIndex, rowIndex)
		let canEdit = sheet.shouldEditCell(at: cellIndex)

		if canEdit,
			case .cell(let col, let row) = selection,
			row == rowIndex && col == colIndex {
			beginEditCell(at: sheet.makeIndex(col, row))
			return
		}

		if sheet.delegate?.sheet(sheet, shouldSelectCellAt: cellIndex) ?? true {
			sheet.setSelection(.cell(column: colIndex, row: rowIndex))
			scrollToSelection(selection, animated: true)
		}
	}

	override func determineRange(
		from topLeft: CGPoint,
		to bottomRight: CGPoint)
	-> SheetCellRange {
		let leftIndex = findColumnIntersecting(offset: topLeft.x)?.index ?? 0
		let rightIndex = findColumnIntersecting(offset: bottomRight.x)?.index ?? columns.count - 1
		let topIndex = findRowIntersecting(offset: topLeft.y)?.index ?? 0
		let bottomIndex = findRowIntersecting(offset: bottomRight.y)?.index ?? rows.count - 1

		return SheetCellRange(
			leftColumn: max(0, leftIndex - 1),
			rightColumn: min(columns.count, rightIndex + 1),
			topRow: max(0, topIndex - 1),
			bottomRow: min(rows.count, bottomIndex + 1))
	}

	func reloadCellsAt(indices: [SheetIndex]) {
		for i in indices {
			if let cell = visibleCells[i] {
				let frame = cell.frame
				sheet.releaseCell(cell)
				let freshCell = sheet.cellFor(i, in: .content)
				addSubview(freshCell)
				freshCell.frame = frame
				visibleCells[i] = freshCell
			}
		}
	}

	func beginEditCell(at index: SheetIndex) {
		let editor = sheet.editorViewFor(index: index)
		editor.frame = sheet.frameRectFor(index: index)
		editor.layer.zPosition = 1
		addSubview(editor)
		editor.becomeFirstResponder()
		editorView = editor
		editorIndex = index
		isEditing = true
	}

	func endEditCell() {
		guard let editorView = editorView else {
			return
		}

		sheet.endCellEditing(at: editorIndex, andRelease: editorView)
		isEditing = false
		editorIndex = .invalid
		self.editorView = nil
	}
}
