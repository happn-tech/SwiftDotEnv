import XCTest

@testable import DotEnv



class DotEnvTests: XCTestCase {
	
	static let envURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("test.env")
	
	override class func setUp() {
		let testEnv = """
			# example comment

			MOCK_STRING=helloMom
			MOCK_INT=42
			MOCK_BOOL=true
			"""
		FileManager.default.createFile(atPath: envURL.path, contents: Data(testEnv.utf8), attributes: nil)
		DotEnv.loadDotEnvFile(path: "test.env")
	}
	
	override class func tearDown() {
		_ = try? FileManager.default.removeItem(at: envURL)
	}
	
	func test_getFromEnv() {
		let actualResult = ProcessInfo.processInfo.environment["MOCK_STRING"]
		XCTAssertEqual(actualResult!, "helloMom")
	}
	
	func test_get_returnsString() {
		let actualResult = DotEnv.get("MOCK_STRING")
		XCTAssertEqual(actualResult, "helloMom")
	}
	
	func test_getSubscript_returnsString() {
		let actualResult = DotEnv["MOCK_STRING"]
		XCTAssertEqual(actualResult, "helloMom")
	}
	
	func test_getAsInt_returnsInt() {
		let actualResult = DotEnv.getAsInt("MOCK_INT")
		XCTAssertEqual(actualResult, 42)
	}
	
	func test_getAsBool_returnsBool() {
		let actualResult = DotEnv.getAsBool("MOCK_BOOL")
		XCTAssertNotNil(actualResult)
		XCTAssertTrue(actualResult!)
	}
	
	func test_comments_AreStripped() {
		let actualResult = DotEnv.get("# example comment")
		XCTAssertNil(actualResult)
	}
	
	func test_emptyLines_AreStripped() {
		let actualResult = DotEnv.get("\r\n")
		XCTAssertNil(actualResult)
	}
	
	func test_all_containsTestEnv() {
		let actual = DotEnv.all
		
		XCTAssertTrue(actual.contains(where: { (key, _) -> Bool in
			return key == "MOCK_STRING"
		}))
		XCTAssertTrue(actual.contains(where: { (key, _) -> Bool in
			return key == "MOCK_INT"
		}))
		XCTAssertTrue(actual.contains(where: { (key, _) -> Bool in
			return key == "MOCK_BOOL"
		}))
	}
	
}
