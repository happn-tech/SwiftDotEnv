import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif



public struct DotEnv {
	
	/**
	Load .env file and put all the variables into the environment. */
	public static func loadDotEnvFile(path: String) {
		let path = path.starts(with: "/") ? path : getAbsolutePath(relativePath: "/\(path)")
		
		if let path = path, let contents = try? String(contentsOfFile: path, encoding: .utf8) {
			let lines = contents.split{ $0 == "\n" || $0 == "\r\n" }.map(String.init)
			for line in lines {
				/* ignore comments */
				guard line[line.startIndex] != "#" else {
					continue
				}
				
				/* ignore lines that appear empty */
				guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
					continue
				}
				
				/* extract key and value which are separated by an equals sign */
				let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
				
				let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
				var value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
				
				/* remove surrounding quotes from value & convert remove escape
				* character before any embedded quotes */
				if value[value.startIndex] == "\"" && value[value.index(before: value.endIndex)] == "\"" {
					value.remove(at: value.startIndex)
					value.remove(at: value.index(before: value.endIndex))
					value = value.replacingOccurrences(of:"\\\"", with: "\"")
				}
				setenv(key, value, 1)
			}
		}
	}
	
	/** Convenience for `ProcessInfo.processInfo.environment` */
	public static var all: [String: String] {
		return ProcessInfo.processInfo.environment
	}
	
	public init(withFile path: String = ".env") {
		loadDotEnvFile(path: path)
	}
	
	public func loadDotEnvFile(path: String) {
		Self.loadDotEnvFile(path: path)
	}
	
	/**
	Return the value for `name` in the environment, returning the default if not
	present. */
	public func get(_ name: String) -> String? {
		guard let value = getenv(name) else {
			return nil
		}
		return String(validatingUTF8: value)
	}
	
	/**
	Return the integer value for `name` in the environment, returning default if
	not present. */
	public func getAsInt(_ name: String) -> Int? {
		guard let value = get(name) else {
			return nil
		}
		return Int(value)
	}
	
	/**
	Return the boolean value for `name` in the environment, returning default if
	not present.
	
	- Note: the value is lowercaed and must be "true", "yes" or "1" to be
	considered true. */
	public func getAsBool(_ name: String) -> Bool? {
		guard let value = get(name) else {
			return nil
		}
		
		/* Is it "true"? */
		if Set(arrayLiteral: "true", "yes", "1").contains(value.lowercased()) {
			return true
		}
		
		return false
	}
	
	/**
	Array subscript access to environment variables as it's cleaner */
	public subscript(key: String) -> String? {
		return get(key)
	}
	
	/** Convenience for `ProcessInfo.processInfo.environment` */
	public var all: [String: String] {
		return ProcessInfo.processInfo.environment
	}
	
	/**
	Determine absolute path of the given argument relative to the current
	directory */
	private static func getAbsolutePath(relativePath: String) -> String? {
		let fileManager = FileManager.default
		let currentPath = fileManager.currentDirectoryPath
		let filePath = currentPath + relativePath
		if fileManager.fileExists(atPath: filePath) {
			return filePath
		} else {
			return nil
		}
	}
}
