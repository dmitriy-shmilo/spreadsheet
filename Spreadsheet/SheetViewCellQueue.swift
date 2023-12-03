//

import Foundation

class SheetViewCellQueue {
	let id: String
	let type: SheetViewCell.Type
	let limit: Int
	var queue = [SheetViewCell]()

	init(id: String, limit: Int, type: SheetViewCell.Type) {
		self.id = id
		self.limit = limit
		self.type = type
		queue.reserveCapacity(limit)
	}

	func enqueue(_ cell: SheetViewCell) {
		if queue.count >= limit {
			return
		}

		queue.append(cell)
	}

	func dequeue() -> SheetViewCell {
		let cell = queue.popLast() ?? type.init(frame: .zero)
		cell.reuseIdentifier = id
		return cell
	}
}
