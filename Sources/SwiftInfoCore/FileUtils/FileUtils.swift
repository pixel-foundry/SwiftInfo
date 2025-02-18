import Foundation

/// Wraps utilities for opening and saving files needed by SwiftInfo.
public struct FileUtils {
    static let supportedInfofilePaths = ["./", "../", "../../", "../../../"]

    /// The path to the Xcode build log.
    public static var buildLogFilePath = ""

    /// The path to the Xcode test log.
    public static var testLogFilePath = ""

    /// The path to the Buck log.
    public static var buckLogFilePath = ""

    let outputFileName = "SwiftInfoOutput.json"
    let infofileName = "Infofile.swift"

    /// A file manager.
    public let fileManager: FileManager

    /// The utility that opens and saves files.
    public let fileOpener: FileOpener

    public init(fileManager: FileManager = .default,
                fileOpener: FileOpener = .init()) {
        self.fileManager = fileManager
        self.fileOpener = fileOpener
    }

    /// The working path that contains the SwiftInfo binary.
    public var toolFolder: String {
        guard let executablePath = Bundle.main.executablePath else {
            fail("Couldn't determine the folder that's running SwiftInfo.")
        }
        return URL(fileURLWithPath: executablePath, isDirectory: false).deletingLastPathComponent().path
    }

    /// The path where Infofile.swift is located.
    public func infofileFolder() throws -> String {
        guard let path = FileUtils.supportedInfofilePaths.first(where: {
            fileManager.fileExists(atPath: $0 + infofileName)
        }) else {
            throw SwiftInfoError.generic("Infofile.swift not found.")
        }
        return path
    }

    /// The contents of the test log located in the `testLogFilePath` path.
    public func testLog() throws -> String {
        let folder = try infofileFolder()
        let url = URL(fileURLWithPath: folder + FileUtils.testLogFilePath)
        do {
            return try fileOpener.stringContents(ofUrl: url)
        } catch {
            throw SwiftInfoError.generic("""
                Test log not found!
                Expected path: \(FileUtils.testLogFilePath)
                Thrown error: \(error.localizedDescription)
            """)
        }
    }

    /// The contents of the buck log located in the `buckLogFilePath` path.
    public func buckLog() throws -> String {
        let folder = try infofileFolder()
        let url = URL(fileURLWithPath: folder + FileUtils.buckLogFilePath)
        do {
            return try fileOpener.stringContents(ofUrl: url)
        } catch {
            throw SwiftInfoError.generic("""
                Buck's log not found!
                Expected path: \(FileUtils.buckLogFilePath)
                Thrown error: \(error.localizedDescription)
            """)
        }
    }

    /// The contents of the build log located in the `buildLogFilePath` path.
    public func buildLog() throws -> String {
        let folder = try infofileFolder()
        let url = URL(fileURLWithPath: folder + FileUtils.buildLogFilePath)
        do {
            return try fileOpener.stringContents(ofUrl: url)
        } catch {
            throw SwiftInfoError.generic("""
                Build log not found!
                Expected path: \(FileUtils.buildLogFilePath)
                Thrown error: \(error.localizedDescription)
            """)
        }
    }

    /// The folder where the output should be stored.
    public func outputFileFolder() throws -> String {
        return (try infofileFolder()) + "SwiftInfo-output/"
    }

    /// The desired file path of the output.
    public func outputFileURL() throws -> URL {
        return URL(fileURLWithPath: (try outputFileFolder()) + outputFileName)
    }

    /// Opens the current output JSON in `outputFileURL()` and returns it as a dictionary.
    public func fullOutput() throws -> [String: Any] {
        guard let data = try? fileOpener.dataContents(ofUrl: try outputFileURL()) else {
            return [:]
        }
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        return object as? [String: Any] ?? [:]
    }

    /// Opens the current output JSON in `outputFileURL()` and returns the array of SwiftInfo executions.
    public func outputArray() throws -> [[String: Any]] {
        return ((try fullOutput())["data"] as? [[String: Any]]) ?? []
    }

    /// Opens the current output JSON in `outputFileURL()` and returns the latest SwiftInfo execution.
    public func lastOutput() throws -> Output {
        let array = try outputArray()
        return Output(rawDictionary: array.first ?? [:], summaries: [], errors: [])
    }

    /// Saves an output dictionary to the `outputFileURL()`.
    public func save(output: [[String: Any]]) throws {
        let path = try outputFileURL()
        log("Path to save: \(path.absoluteString)", verbose: true)
        let dictionary = ["data": output]
        let json = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
        try? fileManager.createDirectory(atPath: try outputFileFolder(),
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        try fileOpener.write(data: json, toUrl: path)
    }

    func parsePlistFromBuildLog(target: String) -> String? {
        guard let log = try? buildLog() else { return nil }
        let pattern = #"ProcessInfoPlistFile [^\n]+ (\/[^\n]+.plist) \(in target '\#(target)' from project '[^\n]+'\)"#
        let match = log.matchResults(regex: pattern)
        let infoPlistPath = match.compactMap { $0.captureGroup(1, originalString: log) }.first
        return infoPlistPath
    }
}

public enum SwiftInfoError: Error, LocalizedError {
    case generic(String)

    public var errorDescription: String? {
        switch self {
        case let .generic(message):
            return message
        }
    }
}
