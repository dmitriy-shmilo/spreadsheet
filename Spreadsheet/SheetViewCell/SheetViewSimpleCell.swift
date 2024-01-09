//

import UIKit

/// A base class for simple cells, which can have a background and border.
open class SheetViewSimpleCell: SheetViewCell {
	/// Gets or sets a `UIColor` to be used as a cell border in the default, not selected state.
	/// Defaults to the `systemGray2` color. Changing this property will update the border and background
	/// of the cell.
	open var normalBorderColor = UIColor.systemGray2 {
		didSet {
			refreshColors()
		}
	}

	/// Gets or sets a `UIColor` to be used as a cell border in the  selected state.
	/// Defaults to the `systemBlue` color. Changing this property will update the border and background
	/// of the cell.
	open var selectedBorderColor = UIColor.systemBlue {
		didSet {
			refreshColors()
		}
	}

	/// Gets or sets a `UIColor` to be used as a cell background in the  default, not selected, state.
	/// Defaults to the `systemBackground` color. Changing this property will update the border and background
	/// of the cell.
	open var normalBackgroundColor: UIColor? = .systemBackground {
		didSet {
			refreshColors()
		}
	}

	/// Gets or sets a `UIColor` to be used as a cell background in the  selected state.
	/// Defaults to the `secondarySystemBackground` color. Changing this property will update the border and background
	/// of the cell.
	open var selectedBackgroundColor: UIColor? = .secondarySystemBackground {
		didSet {
			refreshColors()
		}
	}

	public override var selection: SheetSelection {
		didSet {
			refreshColors()
		}
	}

	public required init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	convenience init(index: SheetIndex) {
		self.init(frame: .zero)
		sheetIndex = index
	}

	/// Not implemented.
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	// MARK: - Public Methods
	open override func prepareForReuse() {
		refreshColors()
	}

	// MARK: - Private Methods
	private func setup() {
		isUserInteractionEnabled = false
		layer.borderWidth = 1.0
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
