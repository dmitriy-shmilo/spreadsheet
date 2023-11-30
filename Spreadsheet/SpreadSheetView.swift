//

import UIKit

public class SpreadsheetView: UIView {

	private var scrollView: SpreadsheetScrollView!

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	private func setup() {
		scrollView = .init(frame: frame)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(scrollView)
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			scrollView.rightAnchor.constraint(equalTo: rightAnchor),
			scrollView.leftAnchor.constraint(equalTo: leftAnchor),
		])
	}
}

class CellContainer {
	var cells = [UIView]()
	var leftIndex = 0
	var topIndex = 0
	var rightIndex = 0
	var bottomIndex = 0

	func shiftHorizontal() {
		let width = rightIndex - leftIndex
	}
}




