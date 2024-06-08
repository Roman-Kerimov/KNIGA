// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import LinguisticKit

do {
    let mdFajlyi = try FileManager.default.contentsOfDirectory(
        at: .currentDirectory(),
        includingPropertiesForKeys: [.contentModificationDateKey]
    )
    .map {
        $0.pathExtension == "md"
    }
} catch {
    fatalError(error.localizedDescription)
}
