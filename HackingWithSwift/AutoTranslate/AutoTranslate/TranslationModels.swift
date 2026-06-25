//
//  TranslationModels.swift
//  AutoTranslate
//
//  Created by Thomas Cowern on 6/25/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct TranslationUnit: Codable {
    var state = "translated"
    var value: String
}

struct TranslationLanguage: Codable {
    var stringUnit: TranslationUnit
}

struct TranslationString: Codable {
    var localizations = [String: TranslationLanguage]()
}

extension UTType {
    static var xcStrings = UTType("com.apple.xcode.xcstrings")!
}

struct TranslationDocument: Codable, FileDocument {
    init(sourceLanguage: String, strings: [String: TranslationString] = [:]) {
        self.sourceLanguage = sourceLanguage
        self.strings = strings
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self = try JSONDecoder().decode(TranslationDocument.self, from: data)
        } else {
            sourceLanguage = "en"
            strings = [:]
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        return FileWrapper(regularFileWithContents: data)
    }
    
    static var readableContentTypes = [UTType.xcStrings]

    var sourceLanguage: String
    var strings: [String: TranslationString]
    var version = "1.0"
}
