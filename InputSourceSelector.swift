// An utility to manipulate Input Sources.
import Foundation
import Carbon

func inputSources(matching properties: CFDictionary? = nil, includeAll: Bool = false) -> [TISInputSource] {
    guard let ref = TISCreateInputSourceList(properties, includeAll) else { return [] }
    return ref.takeRetainedValue() as NSArray as! [TISInputSource]
}

func property(_ key: CFString, of source: TISInputSource) -> String {
    guard let ptr = TISGetInputSourceProperty(source, key) else { return "" }
    return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
}

func printSource(_ source: TISInputSource) {
    let id   = property(kTISPropertyInputSourceID, of: source)
    let name = property(kTISPropertyLocalizedName, of: source)
    print("\(id) (\(name))")
}

func printUsage(_ programName: String) {
    fputs("""
        Usage:
           \(programName) [command]

        Available commands:
           list                        Lists currently installed input sources.
           list-enabled                Lists currently enabled input sources.
           current                     Prints currently selected input source.
           current-layout              Prints currently used keyboard layout.
           enable [input source ID]    Enables specified input source.
           disable [input source ID]   Disables specified input source.
           select [input source ID]    Selects specified input source.
           deselect [input source ID]  Deselects specified input source.\n
        """, stderr)
}

// --- Main ---

let args = CommandLine.arguments
let programName = args[0]

guard args.count > 1 else {
    printUsage(programName)
    exit(0)
}

let command = args[1]

switch command {
case "list", "list-enabled":
    let includeAll = (command == "list")
    for source in inputSources(includeAll: includeAll) {
        printSource(source)
    }

case "current", "current-layout":
    let ref: Unmanaged<TISInputSource> = command == "current-layout"
        ? TISCopyCurrentKeyboardLayoutInputSource()
        : TISCopyCurrentKeyboardInputSource()
    printSource(ref.takeRetainedValue())

case "enable", "disable", "select", "deselect":
    guard args.count > 2 else {
        fputs("Error: '\(command)' requires an input source ID\n", stderr)
        printUsage(programName)
        exit(1)
    }
    let id = args[2]
    let filter = [kTISPropertyInputSourceID as String: id] as CFDictionary
    guard let source = inputSources(matching: filter, includeAll: true).first else {
        fputs("Specified input source \"\(id)\" not found\n", stderr)
        exit(1)
    }
    switch command {
    case "enable":   TISEnableInputSource(source)
    case "disable":  TISDisableInputSource(source)
    case "select":   TISSelectInputSource(source)
    case "deselect": TISDeselectInputSource(source)
    default: break
    }

default:
    printUsage(programName)
    exit(1)
}
