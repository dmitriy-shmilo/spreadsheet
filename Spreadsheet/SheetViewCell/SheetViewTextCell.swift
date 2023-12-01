//

import UIKit

public class SheetViewTextCell: SheetViewCell {
	private static let spacing = 8.0

	private(set) public var label = UILabel()

	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	private func setup() {
		layer.borderWidth = 1.0
		layer.borderColor = UIColor.systemGray2.cgColor
		backgroundColor = .systemBackground

		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .label
		
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
