//

import UIKit

/// A simple cel limplementation, which holds a single text label.
/// Use the ``label`` property to customize the `UILabel` within this cell.
public class SheetViewLabelCell: SheetViewSimpleCell {
	private static let spacing = 8.0

	/// Gets the label, which is the only subview of this cell. Assign its `text` and other properties
	/// in order to display data within this cell.
	private(set) public var label = UILabel()

	public required init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	public override func prepareForReuse() {
		super.prepareForReuse()
		label.text = ""
	}

	// MARK: - Private Methods
	private func setup() {
		isUserInteractionEnabled = false

		layer.borderWidth = 1.0
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textAlignment = .left
		
		addSubview(label)
		NSLayoutConstraint.activate([
			label.topAnchor.constraint(
				equalTo: topAnchor, constant: Self.spacing),
			label.bottomAnchor.constraint(
				equalTo: bottomAnchor, constant: -Self.spacing),
			label.leftAnchor.constraint(
				equalTo: leftAnchor, constant: Self.spacing),
			label.rightAnchor.constraint(
				equalTo: rightAnchor, constant: -Self.spacing),
		])
	}
}
