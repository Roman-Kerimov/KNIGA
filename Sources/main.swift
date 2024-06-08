// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import LinguisticKit

let scriptTable: ScriptTable = .ru
let sourceDirectory: URL = .currentDirectory().appending(component: "KNIGA")

do {
    try FileManager.default.contentsOfDirectory(
        at: sourceDirectory,
        includingPropertiesForKeys: [.contentModificationDateKey]
    )
    .filter {
        $0.pathExtension == "md"
    }
    .forEach { sourceURL in
        func modificationDate(from url: URL) throws -> Date {
            try url
                .resourceValues(forKeys: [.contentModificationDateKey])
                .contentModificationDate!
        }
        
        let sourceModificationDate = try modificationDate(from: sourceURL)
        
        try scriptTable.scripts.forEach { script in
            func targetURL(from script: Script) -> URL {
                URL.currentDirectory()
                    .appending(component: script.rawValue)
                    .appending(component: sourceURL.lastPathComponent)
            }
            
            let targetModificationDate = try? modificationDate(from: targetURL(from: script))
            
            if sourceModificationDate > targetModificationDate {
                let sourceText = try String(contentsOf: sourceURL)
                
                let targetText = if script == .Latn {
                    sourceText
                } else {
                    sourceText
                        .applyingTransform(from: .Latn, to: script, withTable: scriptTable)!
                }
                
                let scriptPicker = scriptTable.scripts
                    .map {
                        if $0 == script {
                            script.rawValue
                        } else {
                            "[\($0)](\(targetURL(from: $0))"
                        }
                    }
                    .joined(separator: " ")
                
                try """
                \(scriptPicker)
                
                \(targetText)
                """
                .write(to: targetURL(from: script), atomically: true, encoding: .utf8)
            }
        }
    }
} catch {
    fatalError(String(describing: error))
}
