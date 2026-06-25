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
    
    @State private var configuration = TranslationSession.Configuration(source: Locale.Language(identifier: "en"), target: Locale.Language(identifier: "es"))
    
    var body: some View {
        VStack {
            TextEditor(text: $input)
                .font(.largeTitle)
                .translationTask(configuration, action: translate)
                .onChange(of: input) { oldValue, newValue in
                    configuration.invalidate()
                }
        }
    }
    
    func translate(using session: TranslationSession) async {
        do {
            let result = try await session.translate(input)
            print(result.targetText)
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}
