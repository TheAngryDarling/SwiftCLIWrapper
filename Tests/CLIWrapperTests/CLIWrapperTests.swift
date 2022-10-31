import XCTest
import CLICapture
@testable import CLIWrapper

class CLIWrapperTests: XCTestCase {
    
    let buffer = CLICapture.STDOutputBuffer()
    
    lazy var wrapper = CLIWrapper.init(supportPreCommandArguments: true,
                                       helpArguments: ["-h"],
                                       outputCapturing: .capture(using: buffer),
                                       executable: URL(fileURLWithPath: "/usr/bin/swift"))
    
    override func setUp() {
        super.setUp()
        
        // setup wrapped commands
        // custom command
        wrapper.createCommand(command: "custom") {
            (_ parent: CLICommandGroup,
             _ argumentStartingAt: Int,
             _ arguments: [String],
             _ environment: [String: String]?,
             _ currentDirectory: URL?,
             _ standardInput: Any?,
             _ userInfo: [String: Any],
             _ stackTrace: CodeStackTrace) throws -> Int32 in
            
            parent.cli.print("Custom Command")
            return 0
        }
        // replace command
        wrapper.createCommand(command: "build") {
            (_ parent: CLICommandGroup,
             _ argumentStartingAt: Int,
             _ arguments: [String],
             _ environment: [String: String]?,
             _ currentDirectory: URL?,
             _ standardInput: Any?,
             _ userInfo: [String: Any],
             _ stackTrace: CodeStackTrace) throws -> Int32 in
            
            parent.cli.print("Replacement Build Command")
            return 0
        }
        
        // PreCLI command
        wrapper.createPreCLICommand(command: "-version") {
            (_ parent: CLICommandGroup,
             _ argumentStartingAt: Int,
             _ arguments: inout [String],
             _ environment: [String: String]?,
             _ currentDirectory: URL?,
             _ userInfo: [String: Any],
             _ stackTrace: CodeStackTrace) throws -> Int32 in
            
            parent.cli.print("PreCLI Command")
            return 0
        }
        
        
        _ = wrapper.createCommandGroupWithCustomAction(command: "test",
                                                   caseSensitive: false,
                                                   helpAction: .passthrough) {
            (_ parent: CLICommandGroup,
             _ argumentStartingAt: Int,
             _ arguments: [String],
             _ environment: [String: String]?,
             _ currentDirectory: URL?,
             _ standardInput: Any?,
             _ userInfo: [String: Any],
             _ stackTrace: CodeStackTrace) throws -> Int32 in
            
            parent.cli.print("Testing default action")
            return 0
        }
        
        // postCLI command
        wrapper.createPostCLICommand(command: "package",
                                     continueOnCLIFailure: true,
                                     passthroughOptions: .all) {
            (_ parent: CLICommandGroup,
             _ argumentStartingAt: Int,
             _ arguments: [String],
             _ environment: [String: String]?,
             _ currentDirectory: URL?,
             _ userInfo: [String: Any],
             _ stackTrace: CodeStackTrace,
             _ exitStatusCode: Int32) throws -> Int32 in
            
            parent.cli.print("package post response")
            return 0
        }
        
        func preWrappedCommand(_ parent: CLICommandGroup,
                               _ argumentStartingAt: Int,
                               _ arguments: inout [String],
                               _ environment: [String: String]?,
                               _ currentDirectory: URL?,
                               _ storage: inout [String: Any]?,
                               _ userInfo: [String: Any],
                               _ stackTrace: CodeStackTrace) throws -> Int32 {
            storage = (storage ?? [:])
            storage?["pre"] = true
            
            parent.cli.print("PreWrapped Command")
            
            return 0
        }
        
        func postWrappedCommand(_ parent: CLICommandGroup,
                                _ argumentStartingAt: Int,
                                _ arguments: [String],
                                _ environment: [String: String]?,
                                _ currentDirectory: URL?,
                                _ storage: [String: Any]?,
                                _ userInfo: [String: Any],
                                _ stackTrace: CodeStackTrace,
                                _ exitStatusCode: Int32) throws -> Int32 {
            guard let storage = storage else {
                parent.cli.printError("Missing storage")
                return -1
            }
            guard let pre = storage["pre"] as? Bool else {
                parent.cli.printError("Missing Pre Storage Tag")
                return -1
            }
            guard pre else {
                parent.cli.printError("Unexpected Pre Storage Tag")
                return -1
            }
            
            parent.cli.print("PostWrapped Command")
            return 0
        }
        
        // wrapped CLI command
        wrapper.createWrappedCommand(command: "run",
                                     continueOnPreActionFailure: true,
                                     continueOnCLIFailure: true,
                                     passthroughOptions: .all,
                                     preActionHandler: preWrappedCommand,
                                     postActionHandler: postWrappedCommand)
    }
    
    func testCustomAction() {
        do {
            let ret = try wrapper.execute(["custom"])
            XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            XCTAssertEqual(str.trimmingCharacters(in: .whitespacesAndNewlines),
                           "Custom Command")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testReplacementAction() {
        do {
            let ret = try wrapper.execute(["build"])
            XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            XCTAssertEqual(str.trimmingCharacters(in: .whitespacesAndNewlines),
                           "Replacement Build Command")
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            let ret = try wrapper.execute(["-Xswiftc", "-DTEST_FLAG", "build"])
            XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            XCTAssertEqual(str.trimmingCharacters(in: .whitespacesAndNewlines),
                           "Replacement Build Command")
        } catch {
            XCTFail("\(error)")
        }
    }
    func testPreAction() {
        do {
            let ret = try wrapper.execute(["-version"])
            XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            XCTAssertTrue(str.contains("PreCLI Command"),
                          "Could not find PreCLI string 'PreCLI Command' in '\(str)'")
            
            XCTAssertTrue(str.contains("Swift version"),
                          "Could not find 'Swift version' in '\(str)'")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    public func testPostAction() {
        do {
            try wrapper.execute(["package"])
            //XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            XCTAssertTrue(str.contains("package post response"),
                          "Could not find PreCLI string 'package post response' in '\(str)'")
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            try wrapper.execute(["-Xswiftc", "-DTEST_FLAG", "package"])
            //XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            XCTAssertTrue(str.contains("package post response"),
                          "Could not find PreCLI string 'package post response' in '\(str)'")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    public func testWrappedAction() {
        
        do {
            try wrapper.execute(["run"])
            //XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            XCTAssertTrue(str.contains("PreWrapped Command"),
                          "Could not find PreCLI string 'PreWrapped Command' in '\(str)'")
            XCTAssertTrue(str.contains("PostWrapped Command"),
                          "Could not find PostCLI string 'PostWrapped Command' in '\(str)'")
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            try wrapper.execute(["-Xswiftc", "-DTEST_FLAG", "run"])
            //XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            XCTAssertTrue(str.contains("PreWrapped Command"),
                          "Could not find PreCLI string 'PreWrapped Command' in '\(str)'")
            XCTAssertTrue(str.contains("PostWrapped Command"),
                          "Could not find PostCLI string 'PostWrapped Command' in '\(str)'")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testHelp() {
        do {
            try wrapper.execute(["-h"])
            //XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            XCTAssertTrue(str.contains("USAGE: swift\n") || str.contains("USAGE: swift [options]"),
                          "Could not find Swift Usage Line in:\n'\(str)'")
        
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            try wrapper.execute(["-h", "package"])
            //XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8)?.replacingOccurrences(of: "\r\n", with: "\n") else {
                XCTFail("Unable to read output as string")
                return
            }
            //print(str)
            XCTAssertTrue(str.contains("USAGE: swift\n") || str.contains("USAGE: swift [options]"),
                          "Could not find Swift Usage Line in:\n'\(str)'")
        
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            try wrapper.execute(["package", "-h"])
            //XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            //print(str)
            XCTAssertTrue(str.contains("USAGE: swift package"),
                          "Could not find Swift Package Usage Line")
        
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            try wrapper.execute(["test", "-h"])
            //XCTAssertEqual(ret, 0)
            guard let str = String(data: buffer.readBuffer(emptyAll: true),
                                   encoding: .utf8) else {
                XCTFail("Unable to read output as string")
                return
            }
            //print(str)
            XCTAssertTrue(str.contains("USAGE: swift test"),
                          "Could not find Swift Test Usage Line")
        
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testLockableReference() {
        // Just making sure we can reference Lockable without importing SynchronizeObjects
        let _: Lockable = NSLock()
    }


    static var allTests = [
        ("testCustomAction", testCustomAction),
        ("testReplacementAction", testReplacementAction),
        ("testPreAction", testPreAction),
        ("testPostAction", testPostAction),
        ("testWrappedAction", testWrappedAction),
        ("testHelp", testHelp),
        ("testLockableReference", testLockableReference)
    ]
}
