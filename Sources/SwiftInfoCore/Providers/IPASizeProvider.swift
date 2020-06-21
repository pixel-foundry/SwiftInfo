import Foundation

/// Size of the .ipa archive (not the App Store size!).
/// Requirements: .ipa available in the `#{PROJECT_DIR}/build` folder.
public struct IPASizeProvider: InfoProvider {
    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "ipa_size"

    public let description: String = "📦 Compressed App Size (.ipa)"
    public let size: Int

    public init(size: Int) {
        self.size = size
    }

    public static func extract(fromApi api: SwiftInfo, args _: Args?) throws -> IPASizeProvider {
        let fileUtils = api.fileUtils
        let infofileFolder = try fileUtils.infofileFolder()
        let enumerator = FileManager.default.enumerator(
            at: URL(fileURLWithPath: infofileFolder),
            includingPropertiesForKeys: [.typeIdentifierKey],
            options: [.skipsPackageDescendants, .skipsHiddenFiles]
        )
        var ipa: URL?
        while let file = enumerator?.nextObject() as? URL {
            guard let identifier = try? file.resourceValues(
                forKeys: [.typeIdentifierKey]
            ).typeIdentifier else { continue }
            if identifier == "com.apple.itunes.ipa" {
                ipa = file
                break
            }
        }
        guard let ipaFile = ipa else {
            throw error(".ipa not found! Attempted to find .ipa in: \(infofileFolder)")
        }
        let attributes = try fileUtils.fileManager.attributesOfItem(atPath: ipaFile.path)
        let fileSize = Int(attributes[.size] as? UInt64 ?? 0)
        return IPASizeProvider(size: fileSize)
    }

    public func summary(comparingWith other: IPASizeProvider?, args _: Args?) -> Summary {
        let prefix = description
        let stringFormatter: ((Int) -> String) = { value in
            let formatter = ByteCountFormatter()
            formatter.allowsNonnumericFormatting = false
            formatter.countStyle = .file
            return formatter.string(fromByteCount: Int64(value))
        }
        return Summary.genericFor(prefix: prefix,
                                  now: size,
                                  old: other?.size,
                                  increaseIsBad: true,
                                  stringValueFormatter: stringFormatter)
    }
}
