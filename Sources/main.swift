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
    .forEach { mdURL in
        mdURL.resourceValues(forKeys: [.contentModificationDateKey])
    }
} catch {
    fatalError(error.localizedDescription)
}
