//

import UIKit

class SheetViewNibCellQueue: SheetViewCellQueue {
	let xib: UINib

	init(id: String, limit: Int, xib: UINib) {
		self.xib = xib
		super.init(id: id, limit: limit)
	}

	override func dequeue() -> SheetViewCell {
		guard let cell = queue.popLast()
		?? xib.instantiate(withOwner: nil).first as? SheetViewCell else {
			fatalError("\(xib) must contain a single view, which can be cast to SheetViewCell")
		}
		cell.reuseIdentifier = id
		print(String(describing: cell))
		return cell
	}
}
