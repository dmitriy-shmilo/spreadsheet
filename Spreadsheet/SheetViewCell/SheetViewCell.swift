//

import UIKit

public class SheetViewCell: UIView {
	internal(set) public var sheetIndex = SheetIndex.invalid

	public override init(frame: CGRect) {
		super.init(frame: frame)
	}

	convenience init(index: SheetIndex) {
		self.init(frame: .zero)
		sheetIndex = index
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
