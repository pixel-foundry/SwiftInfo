import Foundation
import SwiftInfoCore

let task = Process()

public struct Main {
    static func run() {
        let fileUtils = FileUtils()
        log("SwiftInfo 2.3.11")
        if ProcessInfo.processInfo.arguments.contains("-version") {
            exit(0)
        }
        log("Dylib Folder: \(fileUtils.toolFolder)", verbose: true)
        log("Infofile Path: \(try! fileUtils.infofileFolder())", verbose: true)

        let processInfoArgs = ProcessInfo.processInfo.arguments
        let args = Runner.getCoreSwiftCArguments(fileUtils: fileUtils,
                                                 processInfoArgs: processInfoArgs)
            .joined(separator: " ")

        log("Swiftc Args: \(args)", verbose: true)

        task.launchPath = "/bin/bash"
        task.arguments = ["-c", args]
        task.standardOutput = FileHandle.standardOutput
        task.standardError = FileHandle.standardError

        task.terminationHandler = { t -> Void in
            exit(t.terminationStatus)
        }

        task.launch()
    }
}

/////////
// Detect interruptions and use it to interrupt the sub process.
signal(SIGINT, SIG_IGN)
let source = DispatchSource.makeSignalSource(signal: SIGINT)
source.setEventHandler {
    task.interrupt()
    exit(SIGINT)
}

////////

source.resume()
Main.run()
dispatchMain()
