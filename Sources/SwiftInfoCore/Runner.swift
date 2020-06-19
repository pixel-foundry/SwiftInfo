import Foundation

public enum Runner {
    public static func getCoreSwiftCArguments(fileUtils: FileUtils,
                                              toolchainPath: String,
                                              processInfoArgs: [String]) -> [String] {
        let include = fileUtils.toolFolder + "/../include/swiftinfo"
        fatalError(include)
        return [
            "swiftc",
            "--driver-mode=swift", // Don't generate a binary, just run directly.
            "-gnone",
            "-L", // Link with SwiftInfoCore manually.
            include,
            "-I",
            include,
            "-lSwiftInfoCore",
            "-Xcc",
            "-I",
            (try! fileUtils.infofileFolder()) + "Infofile.swift",
            "-toolchain",
            "\(toolchainPath)",
        ] + Array(processInfoArgs.dropFirst()) // Route SwiftInfo args to the sub process
    }
}
