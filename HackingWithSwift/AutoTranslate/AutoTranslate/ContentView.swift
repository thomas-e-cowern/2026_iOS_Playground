//
//  ContentView.swift
//  AutoTranslate
//
//  Created by Thomas Cowern on 6/25/26.
//

import SwiftUI
import Translation

struct ContentView: View {
    
    @State private var input = "Hello World"
    @State private var translatingLanguages = [Language]()
    @State private var languageIndex = Int.max
    @State private var translationState = TranslationState.waiting
    
    @State private var configuration = TranslationSession.Configuration(source: Locale.Language(identifier: "en"), target: Locale.Language(identifier: "es"))
    
    enum TranslationState {
        case waiting, creating, done
    }
    
    @State private var languages = [
        Language(id: "ar", name: "Arabic", isSelected: false),
        Language(id: "zh", name: "Chinese", isSelected: false),
        Language(id: "nl", name: "Dutch", isSelected: false),
        Language(id: "fr", name: "French", isSelected: false),
        Language(id: "de", name: "German", isSelected: false),
        Language(id: "hi", name: "Hindi", isSelected: false),
        Language(id: "in", name: "Indonesian", isSelected: false),
        Language(id: "it", name: "Italian", isSelected: false),
        Language(id: "ja", name: "Japanese", isSelected: false),
        Language(id: "ko", name: "Korean", isSelected: false),
        Language(id: "pl", name: "Polish", isSelected: false),
        Language(id: "pt", name: "Portuguese", isSelected: false),
        Language(id: "ru", name: "Russian", isSelected: false),
        Language(id: "es", name: "Spanish", isSelected: true),
        Language(id: "th", name: "Thai", isSelected: false),
        Language(id: "tr", name: "Turkish", isSelected: false),
        Language(id: "uk", name: "Ukrainian", isSelected: false),
        Language(id: "vi", name: "Vietnamese", isSelected: false),
    ]
    
    var body: some View {
        NavigationSplitView {
            ScrollView {
                Form {
                    ForEach($languages) { $language in
                        Toggle(language.name, isOn: $language.isSelected)
                    }
                }
            }
        } detail: {
            VStack(spacing: 0) {
                TextEditor(text: $input)
                    .font(.largeTitle)

                Button("Create Translations", action: createAllTranslations)
            }
        }
        .translationTask(configuration, action: translate)
        .onChange(of: input) {
            configuration.invalidate()
        }
    }
    
    func translate(using session: TranslationSession) async {
        do {
            if translationState == .creating {
                let result = try await session.translate(input)
                print(result.targetText)

                languageIndex += 1
                doNextTranslation()
            }
        } catch {
            print(error.localizedDescription)
            translationState = .waiting
        }
    }
    
    func doNextTranslation() {
        guard languageIndex < translatingLanguages.count else {
            translationState = .done
            return
        }

        let language = translatingLanguages[languageIndex]
        configuration.source = Locale.Language(identifier: "en")
        configuration.target = Locale.Language(identifier: language.id)
        configuration.invalidate()
    }
    
    func createAllTranslations() {
        translatingLanguages = languages.filter(\.isSelected)
        languageIndex = 0
        translationState = .creating
        doNextTranslation()
    }
}

#Preview {
    ContentView()
}
