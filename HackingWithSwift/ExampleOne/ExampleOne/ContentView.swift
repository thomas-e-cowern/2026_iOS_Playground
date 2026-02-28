import SwiftUI

struct ContentView: View {
    @State private var store = ProjectStore()

    var body: some View {
        TabView {
            ProjectsView()
                .tabItem { Label("Projects", systemImage: "folder") }
            TodayView()
                .tabItem { Label("Today", systemImage: "checkmark.circle") }
            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
        }
        .environment(store)
    }
}

#Preview {
    ContentView()
}
