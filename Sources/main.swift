// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import LinguisticKit

let scriptTable: ScriptTable = .ru

do {
    fatalError(String(describing: KNIGA.type.description))
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
            let targetURL = sourceURL
                .deletingLastPathComponent()
                .appending(component: script.rawValue)
                .appending(component: sourceURL.lastPathComponent)
            
            let targetModificationDate = try sourceURL
                .resourceValues(forKeys: [.contentModificationDateKey])
                .contentModificationDate!
            
            if sourceModificationDate > targetModificationDate {
                let sourceText = try String(contentsOf: sourceURL)
                
                let targetText = if script == .Latn {
                    sourceText
                } else {
                    sourceText
                        .applyingTransform(from: .Latn, to: script, withTable: scriptTable)
                }
                
                let header = scriptTable.scripts
                    .map {
                        if $0 == script {
                            script.rawValue
                        } else {
                            "[\($0)]()"
                        }
                    }
            }
        }
    }
} catch {
    fatalError(error.localizedDescription)
}
