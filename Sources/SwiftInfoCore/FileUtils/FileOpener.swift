import Foundation

open class FileOpener {
    open func stringContents(ofUrl url: URL) throws -> String {
        return try String(contentsOf: url)
    }

    open func dataContents(ofUrl url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }

    open func plistContents(ofPath path: String) -> [String: Any]? {
        var plistFormat = PropertyListSerialization.PropertyListFormat.binary
        guard let plistData = FileManager.default.contents(atPath: path) else { return nil }
        guard let plist = try? PropertyListSerialization.propertyList(
            from: plistData,
            options: [],
            format: &plistFormat
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
