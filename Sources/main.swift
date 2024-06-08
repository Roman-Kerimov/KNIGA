// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import LinguisticKit

do {
    let fajlyi = try FileManager.default.contentsOfDirectory(at: .currentDirectory(), includingPropertiesForKeys: [.mod])
} catch {
    fatalError(error.localizedDescription)
}
