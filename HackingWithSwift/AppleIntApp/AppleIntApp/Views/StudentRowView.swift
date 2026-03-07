//
//  StudentRowView.swift
//  AppleIntApp
//
//  Created by Thomas Cowern on 3/7/26.
//

import SwiftUI

struct StudentRowView: View {
    
    var student: Student
    
    var body: some View {
        Text("\(student.firstName) \(student.lastName)")
            .font(.title)
        Text("Age: \(student.age)")
        Text("Country: \(student.country)")
        Text("Email: \(student.email)")
        Text("Phone: \(student.phone)")
    }
}

#Preview {
    StudentRowView(student: Student(id: "001", firstName: "Jane", lastName: "Smith", age: 22, email: "jsmith@example.com", phone: "123-555-1212", country: "US", address: "123 Main St", city: "West Palm Beach"))
}
