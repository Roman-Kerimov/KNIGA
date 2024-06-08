// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import LinguisticKit

let scriptTable: ScriptTable = .ru

do {
    try FileManager.default.contentsOfDirectory(
        at: .currentDirectory().appending(component: "KNIGA"),
        includingPropertiesForKeys: [.contentModificationDateKey]
    )
    .filter {
        $0.pathExtension == "md"
    }
    .forEach { sourceURL in
        let sourceModificationDate = try sourceURL
            .resourceValues(forKeys: [.contentModificationDateKey])
            .contentModificationDate!
        
        try scriptTable.scripts.forEach { script in
            func targetURL(from script: Script) -> URL {
                sourceURL
                    .deletingLastPathComponent()
                    .appending(component: script.rawValue)
                    .appending(component: sourceURL.lastPathComponent)
            }
            
            let targetModificationDate = try sourceURL
                .resourceValues(forKeys: [.contentModificationDateKey])
                .contentModificationDate!
            
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
                
                try [scriptPicker, targetText]
                    .joined(separator: "\n\n")
                    .write(to: targetURL(from: script), atomically: true, encoding: .utf8)
            }
        }
    }
} catch {
    fatalError(error.localizedDescription)
}
