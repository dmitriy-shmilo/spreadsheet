//

import Foundation

class SheetViewCellQueue {
	let id: String
	let limit: Int
	var queue = [SheetViewCell]()

	init(id: String, limit: Int) {
		self.id = id
		self.limit = limit
		queue.reserveCapacity(limit)
	}

	func enqueue(_ cell: SheetViewCell) {
		if queue.count >= limit {
			return
		}

		queue.append(cell)
	}

	func dequeue() -> SheetViewCell {
		fatalError("dequeue has not been implemented")
	}
}
