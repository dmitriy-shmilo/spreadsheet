//

import UIKit

/// A base class for all cells displayed within a ``SheetView``.
open class SheetViewCell: UIView {
	/// Gets the reuse identifier assigned to this cell if it was instantiated by a reuse queue.
	/// Use ``SheetView/register(_:forCellReuseIdentifier:)`` to create such queues.
	/// Defaults to an empty string.
	internal(set) public var reuseIdentifier = ""

	/// Gets the index, which is assigned to this cell instance when it is placed in the spread sheet.
	/// Default value is ``SheetIndex/invalid``.
	internal(set) public var sheetIndex = SheetIndex.invalid

	/// Gets the ``SheetSelection`` which this cell is a part of or ``SheetSelection/none``
	/// if this cell is not currently selected. This value is assigned once the cell is placed within the spread sheet.
	internal(set) public var selection: SheetSelection = .none

	public required override init(frame: CGRect) {
		super.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	convenience init(index: SheetIndex) {
		self.init(frame: .zero)
		sheetIndex = index
	}

	// MARK: - Public Methods
	/// This method is called once the cell is about to be placed onto the spreadsheet. If the cell was
	/// dequeued with ``SheetView/dequeueReusableCell(withIdentifier:)``, this method
	/// might be called many times for the same cell instance.
	///
	/// > When cells are reused, any stored properties are persisted in their last state. Use this method as an opportunity
	/// to reset any cell subviews or properties to their initial values.
	///
	/// >  `super.prepareForReuse` must be called in subclasses.
	open func prepareForReuse() {
		// no-op
	}
}
