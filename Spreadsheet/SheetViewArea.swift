//

import Foundation

/// Identifies each separate sub-component of a sheetview, which is capable of holding cells.
public enum SheetViewArea {
	/// Erroneous value.
	case unknown

	/// Central, scrollable, main content area where most of the data resides.
	case content

	/// Top scrollable area, which holds fixed rows/headers.
	case fixedTop

	/// Left scrollable area, which holds fixed columns.
	case fixedLeft
}
