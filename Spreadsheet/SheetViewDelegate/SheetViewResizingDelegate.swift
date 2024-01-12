//

import UIKit

/// Assign an implementation of this protocol to ``SheetView/resizingDelegate`` in order to
/// receive resizing-related callbacks and  provide custom resizer views.
public protocol SheetViewResizingDelegate: AnyObject {

	// MARK: - Column Resizing
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

	// MARK: - Row Resizing
	/// Provide a `UIView`, which will serve as a resizing indicator. Return nil to use the default resizer view.
	/// Called by the ``SheetView`` when its ``SheetView/beginResizingColumn(at:)`` is invoked.
	/// Provide ``sheet(_:resizerFrameForColumnAt:)-jfrj`` implementation as well, otherwise this
	/// view will have the default width of 1pt.
	///
	/// > The resulting view will be added as a ``SheetView`` subview, and a strong reference to it will be kept.
	/// > Once the ``SheetView/endResizingColumn()`` is called, this view will removed from superview, and
	/// > all strong references will be erased.
	func sheet(_ sheet: SheetView, resizerViewForRowAt index: Int) -> UIView?

	/// Provide a custom frame for the resizer view, which was returned from
	/// ``sheet(_:resizerViewForColumnAt:)-3g4q7``. The resulting frame is relative to the `sheet`'s
	/// frame.
	func sheet(_ sheet: SheetView, resizerFrameForRowAt offset: CGFloat) -> CGRect

	/// Called by a `sheet`, when ``SheetView/endResizingColumn()`` was called, but only after
	/// ``SheetView/beginResizingColumn(at:)``.
	func sheet(_ sheet: SheetView, didEndResizingRowAt index: Int, to height: CGFloat)
}

// MARK: - Default Implementation
public extension SheetViewResizingDelegate {
	
	// MARK: - Column Resizing
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

	// MARK: - Row Resizing
	func sheet(_ sheet: SheetView, resizerViewForRowAt index: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = .systemBlue
		view.isUserInteractionEnabled = false
		return view
	}

	func sheet(_ sheet: SheetView, resizerFrameForRowAt offset: CGFloat) -> CGRect {
		return .init(x: 0.0, y: offset, width: sheet.frame.width, height: 1.0)
	}

	func sheet(_ sheet: SheetView, didEndResizingRowAt index: Int, to height: CGFloat) {
		sheet.setHeight(height, for: index)
	}
}
