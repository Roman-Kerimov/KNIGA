// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import LinguisticKit

let sourcesURL: URL = .currentDirectory()
    .appending(component: "Sources")

let scriptTable: ScriptTable = .ru

let sourcePath = "Iskhodniki"

let sourceDirectory: URL = .currentDirectory()
    .appending(path: sourcePath)

func targetDirectory(script: Script) -> URL {
    URL.currentDirectory()
        .appending(component: script.rawValue)
}

func modificationDate(from url: URL) throws -> Date {
    try url
        .resourceValues(forKeys: [.contentModificationDateKey])
        .contentModificationDate!
}

let mainSwiftModificationDate = try modificationDate(
    from: sourcesURL.appending(component: "main.swift")
)

let packageResolvedModificationDate = try modificationDate(
    from: .currentDirectory().appending(path: "Package.resolved")
)

extension String {
    func addingFileNamePercentEncoding() -> String {
        addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    }
}

do {
    for script in scriptTable.scripts {
        let targetDirectoryModificationDate = try modificationDate(
            from: targetDirectory(script: script)
        )
        let shouldRemoveTargetDirectories = [mainSwiftModificationDate, packageResolvedModificationDate]
            .map { $0 > targetDirectoryModificationDate }
            .contains(true)
        
        if shouldRemoveTargetDirectories {
            try scriptTable.scripts.forEach { script in
                try FileManager.default
                    .removeItem(at: targetDirectory(script: script))
            }
            
            break
        }
    }
    
    try {
        try FileManager.default.contentsOfDirectory(
            at: sourceDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        )
        .filter {
            $0.pathExtension == "md"
        }
    }()
    .forEach { sourceURL in
        let sourceModificationDate = try modificationDate(from: sourceURL)
        
        try scriptTable.scripts.forEach { script in
            func targetURL(from script: Script) -> URL {
                let targetDirectory = targetDirectory(script: script)
                
                try? FileManager.default
                    .createDirectory(at: targetDirectory, withIntermediateDirectories: true)
                
                return targetDirectory
                    .appending(
                        component: sourceURL
                            .deletingPathExtension()
                            .lastPathComponent
                            .applyingTransform(from: .Latn, to: script, withTable: scriptTable)!
                    )
                    .appendingPathExtension(sourceURL.pathExtension)
            }
            
            let targetModificationDate = try? modificationDate(from: targetURL(from: script))
            
            guard
                targetModificationDate.map({
                    sourceModificationDate > $0
                    || mainSwiftModificationDate < $0
                    || packageResolvedModificationDate < $0
                }) ?? true
            else {
                return
            }
            
            let sourceText = (try String(contentsOf: sourceURL))
                .replacing(#/\[\[[\w|\s]+\]\]/#) { match in
                    let wikilinkComponents = match.output
                        .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                        .components(separatedBy: "|")
                    
                    let file = wikilinkComponents.first!
                        .addingFileNamePercentEncoding()
                        .capitalized(with: Locale(languageCode: .russian))
                    
                    let label = wikilinkComponents.last!
                    
                    return "[\(label)](\(file).md)"
                }
            
            let mdLinkPattern = ".md)"
            
            let targetText = if script == .Latn {
                sourceText
            } else {
                sourceText
                    .applyingTransform(from: .Latn, to: script, withTable: scriptTable)!
                    .replacing(
                        mdLinkPattern
                            .applyingTransform(from: .Latn, to: script, withTable: scriptTable)!,
                        with: mdLinkPattern
                    )
            }
            
            let scriptPicker = scriptTable.scripts.sorted()
                .map { script in
                    let scriptLabel = Locale(languageCode: .russian)
                        .localizedString(forScriptCode: script.rawValue)?
                        .applyingTransform(from: .Cyrl, to: script, withTable: scriptTable)
                    ?? script.rawValue
                    
                    return (script: script, label: scriptLabel)
                }
                .sorted(by: { $0.label < $1.label })
                .map {
                    let selectedScript = script
                    let script = $0.script
                    let scriptLabel = $0.label.uppercased()
                    
                    return if script == selectedScript {
                        scriptLabel
                    } else {
                        "[\(scriptLabel)](../\(script)/\(targetURL(from: script).lastPathComponent.addingFileNamePercentEncoding()))"
                    }
                }
                .joined(separator: " | ")
            
            try """
            ### \(scriptPicker)
            [iskhodnik](../\(sourcePath)/\(sourceURL.lastPathComponent.addingFileNamePercentEncoding()))
            
            \(targetText)
            """
            .write(to: targetURL(from: script), atomically: true, encoding: .utf8)
        }
    }
} catch {
    fatalError(String(describing: error))
}
