//

import UIKit

public class SheetViewCell: UIView {
	internal(set) public var sheetIndex = SheetIndex.invalid

	public var selection = SheetSelection.none

	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	convenience init(index: SheetIndex) {
		self.init(frame: .zero)
		sheetIndex = index
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setup() {
		isUserInteractionEnabled = false
		layer.borderWidth = 1.0
		layer.borderColor = UIColor.systemGray2.cgColor
		backgroundColor = .systemBackground
	}
}
