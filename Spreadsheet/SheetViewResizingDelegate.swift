//

import UIKit

/// Assign an implementation of this protocol to ``SheetView/resizingDelegate`` in order to
/// receive resizing-related callbacks and  provide custom resizer views.
public protocol SheetViewResizingDelegate: AnyObject {

	/// Provide a `UIView`, which will serve as a resizing indicator. Return nil to use the default resizer view.
	/// Called by the ``SheetView`` when its ``SheetView/beginResizingColumn(at:)`` is invoked.
	/// Provide ``sheet(_:resizerFrameForColumnAt:)-jfrj`` implementation as well, otherwise this
	/// view will have the default width of 1pt.
	///
	/// > The resulting view will be added as a ``SheetView`` subview, and a strong reference to it will be kept.
	/// > Once the ``SheetView/endResizingColumn()`` is called, this view will removed from superview, and
	/// > all strong references will be erased.
	func sheet(_ sheet: SheetView, resizerViewForColumnAt index: Int) -> UIView?

	/// Provide a custom frame for the resizer view, which was returned from
	/// ``sheet(_:resizerViewForColumnAt:)-3g4q7``. The resulting frame is relative to the `sheet`'s
	/// frame.
	func sheet(_ sheet: SheetView, resizerFrameForColumnAt offset: CGFloat) -> CGRect

	/// Called by a `sheet`, when ``SheetView/endResizingColumn()`` was called, but only after
	/// ``SheetView/beginResizingColumn(at:)``.
	func sheet(_ sheet: SheetView, didEndResizingColumnAt index: Int, to width: CGFloat)
}

public extension SheetViewResizingDelegate {
	func sheet(_ sheet: SheetView, resizerViewForColumnAt index: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .systemBlue
		view.isUserInteractionEnabled = false
		return view
	}

	func sheet(_ sheet: SheetView, resizerFrameForColumnAt offset: CGFloat) -> CGRect {
		return .init(x: offset, y: 0, width: 1.0, height: sheet.frame.height)
	}
	
	func sheet(_ sheet: SheetView, didEndResizingColumnAt index: Int, to width: CGFloat) {
		sheet.setWidth(width, for: index)
	}
}
