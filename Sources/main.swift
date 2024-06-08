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
            .contentModificationDate
        
        let targetURL = sourceURL
            .deletingLastPathComponent()
            .appending(component: "Cyrl")
            .appending(component: sourceURL.lastPathComponent)
        
        ScriptTable.ru.scripts
    }
} catch {
    fatalError(error.localizedDescription)
}
