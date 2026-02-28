import Foundation

// A simple on-device AI stub that performs a "Swiss cheese" breakdown.
// In production, replace the heuristic with Foundation Models when available.
struct AIBreakdownService {
    func breakdown(projectName: String, notes: String) -> [String] {
        // Heuristic: extract nouns/verbs and generate small actionable steps.
        // For now, return a templated set of actionable slices.
        let base = projectName.isEmpty ? "Project" : projectName
        var tasks: [String] = []
        tasks.append("Clarify scope and success criteria for \(base)")
        tasks.append("List constraints, resources, and deadlines for \(base)")
        tasks.append("Create outline or architecture for \(base)")
        tasks.append("Identify 3-5 smallest next actions for \(base)")
        tasks.append("Schedule first 30-minute focused block for \(base)")
        tasks.append("Prepare materials and references for \(base)")
        tasks.append("Implement first slice of \(base)")
        tasks.append("Review progress and adjust plan for \(base)")
        // Optionally use notes keywords to add a few specific steps
        let keywords = notes.split(separator: " ").map(String.init).filter { $0.count > 4 }.prefix(3)
        for key in keywords {
            tasks.append("Research or gather assets related to \(key)")
        }
        return tasks
    }
}
