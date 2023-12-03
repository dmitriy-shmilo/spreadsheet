//

import UIKit

public class SheetViewTextCell: SheetViewCell {
	private static let spacing = 8.0

	public var normalBorderColor = UIColor.systemGray2 {
		didSet {
			refreshColors()
		}
	}

	public var selectedBorderColor = UIColor.systemBlue {
		didSet {
			refreshColors()
		}
	}

	public var normalBackgroundColor: UIColor? {
		didSet {
			refreshColors()
		}
	}

	public var selectedBackgroundColor: UIColor? {
		didSet {
			refreshColors()
		}
	}

	public override var selection: SheetSelection {
		didSet {
			refreshColors()
		}
	}
	

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
		label.text = ""
	}

	private func refreshColors() {
		label.textColor = .label
		if case .none = selection {
			layer.borderColor = normalBorderColor.cgColor
			backgroundColor = normalBackgroundColor
		} else {
			layer.borderColor = selectedBorderColor.cgColor
			backgroundColor = selectedBackgroundColor
		}
	}

	private func setup() {
		isUserInteractionEnabled = false

		refreshColors()
		layer.borderWidth = 1.0
		label.translatesAutoresizingMaskIntoConstraints = false
		
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
