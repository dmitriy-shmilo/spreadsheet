//

import UIKit

/// A base class for all cells displayed within a ``SheetView``.
public class SheetViewCell: UIView {
	/// Gets the reuse identifier assigned to this cell if it was instantiated by a reuse queue.
	/// Use ``SheetView/register(_:forCellReuseIdentifier:)`` to create such queues.
	/// Defaults to an empty string.
	internal(set) public var reuseIdentifier = ""

	/// Gets the index, which is assigned to this cell instance when it is placed in the spread sheet.
	/// Default value is ``SheetIndex/invalid``.
	internal(set) public var sheetIndex = SheetIndex.invalid

	/// Gets or sets a `UIColor` to be used as a cell border in the default, not selected state.
	/// Defaults to the `systemGray2` color. Changing this property will update the border and background
	/// of the cell.
	public var normalBorderColor = UIColor.systemGray2 {
		didSet {
			refreshColors()
		}
	}

	/// Gets or sets a `UIColor` to be used as a cell border in the  selected state.
	/// Defaults to the `systemBlue` color. Changing this property will update the border and background
	/// of the cell.
	public var selectedBorderColor = UIColor.systemBlue {
		didSet {
			refreshColors()
		}
	}

	/// Gets or sets a `UIColor` to be used as a cell background in the  default, not selected, state.
	/// Defaults to the `systemBackground` color. Changing this property will update the border and background
	/// of the cell.
	public var normalBackgroundColor: UIColor? = .systemBackground {
		didSet {
			refreshColors()
		}
	}

	/// Gets or sets a `UIColor` to be used as a cell background in the  selected state.
	/// Defaults to the `secondarySystemBackground` color. Changing this property will update the border and background
	/// of the cell.
	public var selectedBackgroundColor: UIColor? = .secondarySystemBackground {
		didSet {
			refreshColors()
		}
	}

	/// Gets the ``SheetSelection`` which this cell is a part of or ``SheetSelection/none``
	/// if this cell is not currently selected. This value is assigned once the cell is placed within the spread sheet.
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

	/// Not implemented.
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Public Methods
	/// This method is called once the cell is about to be placed onto the spreadsheet. If the cell was
	/// dequeued with ``SheetView/dequeueReusableCell(withIdentifier:)``, this method
	/// might be called many times for the same cell instance.
	///
	/// > When cells are reused, any stored properties are persisted in their last state. Use this method as an opportunity
	/// to reset any cell subviews or properties to their initial values.
	///
	/// >  `super.prepareForReuse` must be called in subclasses, unless the default border and background
	/// > handling is not desired.
	public func prepareForReuse() {
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
