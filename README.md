# CLI Wrapper

![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
[![Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat)](LICENSE.md)

Classes and objects used to wrap a CLI application.  
This includes pre, post, and wrapped CLI processing as well as replacing and adding new cli commands

## Requirements

* Xcode 9+ (If working within Xcode)
* Swift 4.0+

## Usage

```swift

    var wrapper = CLIWrapper.init(helpArguments: ["-h"], // identifiable help arguments
                                  executable: URL(fileURLWithPath: "/usr/bin/swift")) // path to CLI application
                                       
    // custom command
    wrapper.createCommand(command: "custom") {
        (_ parent: CLICommandGroup,
         _ argumentStartingAt: Int,
         _ arguments: [String],
         _ environment: [String: String]?,
         _ currentDirectory: URL?,
         _ standardInput: Any?) throws -> Int32 in
        // Print to STD Out
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
         _ standardInput: Any?) throws -> Int32 in
        
        // Print to STD Out
        parent.cli.print("Replacement Build Command")
        return 0
    }

    // PreCLI command
    wrapper.createPreCLICommand(command: "-version") {
        (_ parent: CLICommandGroup,
         _ argumentStartingAt: Int,
         _ arguments: inout [String],
         _ environment: [String: String]?,
         _ currentDirectory: URL?) throws -> Int32 in
        
        // Print to STD Out
        parent.cli.print("PreCLI Command")
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
         _ exitStatusCode: Int32) throws -> Int32 in
        // Print to STD Out
        parent.cli.print("package post response")
        return 0
    }

    func preWrappedCommand(_ parent: CLICommandGroup,
                           _ argumentStartingAt: Int,
                           _ arguments: inout [String],
                           _ environment: [String: String]?,
                           _ currentDirectory: URL?,
                           _ storage: inout [String: Any]?) throws -> Int32 {
        // Setup or retrive working storage
        storage = (storage ?? [:])
        // Save details into working storage that gets passed to post cli action
        storage?["pre"] = true
        
        // Print to STD Out
        parent.cli.print("PreWrapped Command")
        
        return 0
    }

    func postWrappedCommand(_ parent: CLICommandGroup,
                            _ argumentStartingAt: Int,
                            _ arguments: [String],
                            _ environment: [String: String]?,
                            _ currentDirectory: URL?,
                            _ storage: [String: Any]?,
                            _ exitStatusCode: Int32) throws -> Int32 {
        // Get working storage
        guard let storage = storage else {
            // Print to STD Err
            parent.cli.printError("Missing storage")
            return -1
        }
        // Get save details from storage
        guard let pre = storage["pre"] as? Bool else {
            // Print to STD Err
            parent.cli.printError("Missing Pre Storage Tag")
            return -1
        }
        // testing that saved details matches
        guard pre else {
            // Print to STD Err
            parent.cli.printError("Unexpected Pre Storage Tag")
            return -1
        }
        // Print to STD Out
        parent.cli.print("PostWrapped Command")
        return 0
    }

    // wrapped CLI command
    wrapper.createWrappedCommand(command: "run",
                                 // Indicator if should continue on pre-action failure
                                 continueOnPreActionFailure: true, 
                                 // Indicator if should continue on CLI failure
                                 continueOnCLIFailure: true,
                                 // Indicator of what output from CLI application should
                                 // be directed to STD Out and STD Err
                                 passthroughOptions: .all,
                                 // Action to execute prior to CLI application
                                 preActionHandler: preWrappedCommand,
                                 // Action to execute after CLI application
                                 postActionHandler: postWrappedCommand)
                                 
    try wrapper.execute([.. argumetns ..])
                                       
```

## Dependencies

* **[CLICapture](https://github.com/TheAngryDarling/SwiftCLICapture.git)** - Classes for capturing the output of a CLI application
* **[RegEx](https://github.com/TheAngryDarling/SwiftRegEx.git)** - Swift friendly wrapper around NSRegularExpression

## Author

* **Tyler Anger** - *Initial work* 

## License

*Copyright 2022 Tyler Anger*

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[HERE](LICENSE.md) or [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
