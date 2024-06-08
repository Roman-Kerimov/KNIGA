// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import LinguisticKit

do {
    try FileManager.default.contentsOfDirectory(
        at: .currentDirectory(),
        includingPropertiesForKeys: [.contentModificationDateKey]
    )
    .filter {
        $0.pathExtension == "md"
    }
    .forEach { sourceURL in
        let sourceModificationDate = try sourceURL
            .resourceValues(forKeys: [.contentModificationDateKey])
            .contentModificationDate!
        
        ScriptTable.ru.scripts.forEach { script in
            let targetURL = sourceURL
                .deletingLastPathComponent()
                .appending(component: script.rawValue)
                .appending(component: sourceURL.lastPathComponent)
            
            let targetModificationDate = try sourceURL
                .resourceValues(forKeys: [.contentModificationDateKey])
                .contentModificationDate!
            
            if sourceModificationDate > targetModificationDate {
                
            }
        }
    }
} catch {
    fatalError(error.localizedDescription)
}
