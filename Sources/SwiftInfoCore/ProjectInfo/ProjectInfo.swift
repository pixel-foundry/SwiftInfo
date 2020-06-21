import Foundation

public struct ProjectInfo: CustomStringConvertible {
    let xcodeproj: String
    let target: String
    let configuration: String
    let fileUtils: FileUtils
    let plistPath: String
    let versionString: String?
    let buildNumber: String?

    /// A visual description of this project.
    public var description: String {
        let version: String
        do {
            version = "\(try getVersionString()) (\(try getBuildNumber()))"
        } catch {
            version = "(Failed to retrieve version info)"
        }
        return "\(target) \(version) - \(configuration)"
    }

    public init(xcodeproj: String,
                target: String,
                configuration: String,
                plistPath: String? = nil,
                versionString: String? = nil,
                buildNumber: String? = nil,
                fileUtils: FileUtils = .init()) {
        self.xcodeproj = xcodeproj
        self.target = target
        self.configuration = configuration
        self.versionString = versionString
        self.buildNumber = buildNumber
        self.fileUtils = fileUtils
        self.plistPath = plistPath ?? fileUtils.parsePlistFromBuildLog(target: target) ?? ""
        SwiftInfoCore.log("plistPath: \(self.plistPath)")
    }

    func plistDict() throws -> [String: Any] {
        let path: String
        if let folder = try? fileUtils.infofileFolder() {
            path = folder + plistPath
        } else {
            path = plistPath
        }
        guard let dictionary = fileUtils.fileOpener.plistContents(ofPath: path) ??
            fileUtils.fileOpener.plistContents(ofPath: plistPath) else {
            throw SwiftInfoError.generic("Failed to load plist \(path)")
        }
        return dictionary
    }

    func getVersionString() throws -> String {
        if let versionString = versionString {
            return versionString
        }
        let plist = try plistDict()
        guard let version = plist["CFBundleShortVersionString"] as? String else {
            throw SwiftInfoError.generic("Project version not found.")
        }
        return version
    }

    func getBuildNumber() throws -> String {
        if let buildNumber = buildNumber {
            return buildNumber
        }
        let plist = try plistDict()
        guard let version = plist["CFBundleVersion"] as? String else {
            throw SwiftInfoError.generic("Project build number not found.")
        }
        return version
    }
}
