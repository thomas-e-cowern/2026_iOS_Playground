//
//  GenerableView.swift
//  AppleIntApp
//
//  Created by Thomas Cowern on 3/6/26.
//

import SwiftUI
import FoundationModels

@Generable
struct Student: Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var age: Int
    var email: String
    var phone: String
    var country: String
    var address: String
    var city: String
}

@Generable
struct Directory {
    var students: [Student]
}

struct GenerableView: View {
    
    @State private var session = LanguageModelSession()
    
    @State private var directory = Directory(students: [])
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Spacer()
                
                if directory.students.count < 1 {
                    Text("There are no students in the directory.")
                } else {
                    ScrollView {
                        ForEach(directory.students) { student in
                            StudentRowView(student: student)
                        }
                    }
                    .padding(10)
                }
                
                Spacer()
                
                Button {
                    generateADirectory()
                } label: {
                    Text("Generate Directory")
                }
            }
        }

    }
    
    func generateADirectory() {
        Task {
            do {
                let response = try await session.respond(to: "Generate a school  directory of 5 students.", generating: Directory.self)
                
                print(response)
                
                directory = response.content
            } catch {
                print("There was an error in generating the directory: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    GenerableView()
}
