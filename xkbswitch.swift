import Foundation
import Carbon

enum Mode { case get, set, list }

func usage(_ name: String) {
    print("""
        Usage: \(name) -g|s|l [-n|e] [value]
        -g get mode
        -s set mode
        -n setting and getting by id mode (default)
        -e setting and getting by string mode
        -l list all available layouts (their names)
        """)
}

func inputSources(matching properties: CFDictionary? = nil, includeAll: Bool = false) -> [TISInputSource] {
    guard let ref = TISCreateInputSourceList(properties, includeAll) else { return [] }
    return ref.takeRetainedValue() as NSArray as! [TISInputSource]
}

func property(_ key: CFString, of source: TISInputSource) -> String? {
    guard let ptr = TISGetInputSourceProperty(source, key) else { return nil }
    return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
}

// --- Argument parsing ---

var args = CommandLine.arguments
let programName = args.removeFirst()

guard !args.isEmpty else {
    usage(programName)
    exit(1)
}

var mode: Mode = .get
var useLocalizedName = false

var nonFlagArgs: [String] = []
for arg in args {
    if arg.hasPrefix("-") {
        for ch in arg.dropFirst() {
            switch ch {
            case "g": mode = .get
            case "s": mode = .set
            case "l": mode = .list
            case "n": useLocalizedName = false
            case "e": useLocalizedName = true
            default:
                usage(programName)
                exit(1)
            }
        }
    } else {
        nonFlagArgs.append(arg)
    }
}

let by: CFString = useLocalizedName ? kTISPropertyLocalizedName : kTISPropertyInputSourceID

// --- Execute ---

switch mode {
case .list:
    for source in inputSources() {
        if let prop = property(by, of: source) { print(prop) }
    }

case .get:
    let source = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    if let prop = property(by, of: source) { print(prop) }

case .set:
    if useLocalizedName {
        fputs("not support set by name, please use -n\n", stderr)
        exit(1)
    }
    guard let id = nonFlagArgs.first else {
        fputs("Error: missing input source ID\n", stderr)
        usage(programName)
        exit(1)
    }
    let filter = [kTISPropertyInputSourceID as String: id] as CFDictionary
    guard let source = inputSources(matching: filter, includeAll: true).first else {
        fputs("Specified input source \"\(id)\" not found\n", stderr)
        exit(1)
    }
    TISSelectInputSource(source)
}
