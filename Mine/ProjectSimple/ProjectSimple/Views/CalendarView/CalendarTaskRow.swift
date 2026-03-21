//
//  CalendarTaskRow.swift
//  ProjectSimple
//
//  Created by Thomas Cowern on 3/18/26.
//

import SwiftUI

struct CalendarTaskRow: View {
    let project: Project
    let task: ProjectTask

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color(for: project.colorName))
                .frame(width: 4, height: 40)
                .accessibilityHidden(true)

            Image(systemName: task.status.icon)
                .foregroundStyle(statusColor)
                .font(.title3)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(task.status == .completed, color: .secondary)

                Text(project.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(task.priority.rawValue)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(priorityColor.opacity(0.15))
                .foregroundStyle(priorityColor)
                .clipShape(Capsule())

            if task.recurrenceRule != .none {
                Image(systemName: "arrow.clockwise")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if !task.steps.isEmpty {
                HStack(spacing: 2) {
                    Image(systemName: "checklist")
                        .font(.caption2)
                    Text("\(task.completedStepsCount)/\(task.steps.count)")
                        .font(.caption2)
                }
                .foregroundStyle(task.completedStepsCount == task.steps.count ? .green : .secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(project.name), \(task.status.rawValue), \(task.priority.rawValue) priority\(task.recurrenceRule != .none ? ", repeats \(task.recurrenceRule.rawValue.lowercased())" : "")\(!task.steps.isEmpty ? ", \(task.completedStepsCount) of \(task.steps.count) steps done" : "")")
    }

    private var statusColor: Color {
        switch task.status {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        }
    }

    private var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    private func color(for name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        case "green": return .green
        case "pink": return .pink
        default: return .blue
        }
    }
}
