import Foundation

open class FileOpener {
    open func stringContents(ofUrl url: URL) throws -> String {
        return try String(contentsOf: url)
    }

    open func dataContents(ofUrl url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }

    open func plistContents(ofPath path: String) -> [String: Any]? {
        SwiftInfoCore.log(path)
        guard let plistData = FileManager.default.contents(atPath: path) else { fatalError("Couldn't load Plist from \(path)") }
        guard let plist = try? PropertyListSerialization.propertyList(
            from: plistData,
            options: [],
            format: nil
        ) else {
            return nil
        }
        return plist as? [String: Any]
    }

    open func write(data: Data, toUrl url: URL) throws {
        try data.write(to: url)
    }

    public init() {}
}
