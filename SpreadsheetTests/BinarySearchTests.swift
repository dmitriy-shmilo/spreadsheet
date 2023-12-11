//

import XCTest
@testable import Spreadsheet

final class BinarySearchTests: XCTestCase {

	var sut = [SheetColumnDefinition]()

	override func setUpWithError() throws {
		sut = (0..<20).map {
			return SheetColumnDefinition(index: $0, width: 100.0, offset: CGFloat($0) * 100.0)
		}
	}

	override func tearDownWithError() throws {
		sut = []
	}

	func test_binarySearch_firstElement() {
		let offset = 10.0
		let result = sut.binarySearch {
			if $0.offset > offset {
				return .orderedAscending
			}

			if $0.offset + $0.width < offset {
				return .orderedDescending
			}

			return .orderedSame
		}
		XCTAssertEqual(result?.index, 0)
	}

	func test_binarySearch_lastElement() {
		let offset = sut.last!.offset + 10.0
		let result = sut.binarySearch {
			if $0.offset > offset {
				return .orderedAscending
			}

			if $0.offset + $0.width < offset {
				return .orderedDescending
			}

			return .orderedSame
		}
		XCTAssertEqual(result?.index, sut.count - 1)
	}

	func test_binarySearch_midElement() {
		let offset = sut[10].offset + 10.0
		let result = sut.binarySearch {
			if $0.offset > offset {
				return .orderedAscending
			}

			if $0.offset + $0.width < offset {
				return .orderedDescending
			}

			return .orderedSame
		}
		XCTAssertEqual(result?.index, 10)
	}

	func test_binarySearch_notFoundTooLarge() {
		let offset = 2001.0
		let result = sut.binarySearch {
			if $0.offset > offset {
				return .orderedAscending
			}

			if $0.offset + $0.width < offset {
				return .orderedDescending
			}

			return .orderedSame
		}
		XCTAssertEqual(result, nil)
	}

	func test_binarySearch_notFoundTooSmall() {
		let offset = -1.0
		let result = sut.binarySearch {
			if $0.offset > offset {
				return .orderedAscending
			}

			if $0.offset + $0.width < offset {
				return .orderedDescending
			}

			return .orderedSame
		}
		XCTAssertEqual(result, nil)
	}
}
