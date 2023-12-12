//

import Foundation

extension CGRect {
	func centerOf(size: CGSize) -> CGRect {
		let resultWidth = min(size.width, width)
		let resultHeight = min(size.height, height)

		return .init(
			x: minX + (width - resultWidth) / 2,
			y: minY + (height - resultHeight) / 2,
			width: resultWidth,
			height: resultHeight)
	}

	func limitedBy(size: CGSize) -> CGRect {
		return .init(
			x: minX,
			y: minY,
			width: min(width, size.width),
			height: min(height, size.height))
	}
}
