//

import UIKit

public class SheetViewCell: UIView {
	internal(set) public var reuseIdentifier = ""
	internal(set) public var sheetIndex = SheetIndex.invalid

	internal(set) public var normalBorderColor = UIColor.systemGray2 {
		didSet {
			refreshColors()
		}
	}

	internal(set) public var selectedBorderColor = UIColor.systemBlue {
		didSet {
			refreshColors()
		}
	}

	internal(set) public var normalBackgroundColor: UIColor? = .systemBackground {
		didSet {
			refreshColors()
		}
	}

	internal(set) public var selectedBackgroundColor: UIColor? = .systemBlue.withAlphaComponent(0.3) {
		didSet {
			refreshColors()
		}
	}

	internal(set) public var selection: SheetSelection = .none {
		didSet {
			refreshColors()
		}
	}

	public required override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	convenience init(index: SheetIndex) {
		self.init(frame: .zero)
		sheetIndex = index
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func prepareForReuse() {
		// no-op
	}

	private func setup() {
		isUserInteractionEnabled = false
		layer.borderWidth = 1.0
		refreshColors()
	}

	private func refreshColors() {
		if case .none = selection {
			layer.borderColor = normalBorderColor.cgColor
			backgroundColor = normalBackgroundColor
		} else {
			layer.borderColor = selectedBorderColor.cgColor
			backgroundColor = selectedBackgroundColor
		}
	}
}
