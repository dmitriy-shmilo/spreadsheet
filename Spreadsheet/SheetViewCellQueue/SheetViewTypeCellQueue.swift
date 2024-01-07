//

import Foundation

class SheetViewTypeCellQueue: SheetViewCellQueue {
	let type: SheetViewCell.Type

	init(id: String, limit: Int, type: SheetViewCell.Type) {
		self.type = type
		super.init(id: id, limit: limit)
	}

	override func dequeue() -> SheetViewCell {
		let cell = queue.popLast() ?? type.init(frame: .zero)
		cell.reuseIdentifier = id
		return cell
	}
}
