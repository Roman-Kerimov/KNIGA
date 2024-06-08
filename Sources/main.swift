// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import LinguisticKit

do {
    let try FileManager.default.contentsOfDirectory(
        atPath: FileManager.default.currentDirectoryPath
    )
} catch {
    fatalError(error.localizedDescription)
}
