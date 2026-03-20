//
//  TaskRow.swift
//  ProjectSimple
//
//  Created by Thomas Cowern on 3/19/26.
//

import SwiftUI
import TipKit

struct TaskRow: View {
    @Environment(ProjectStore.self) private var store
    let task: ProjectTask
    let projectID: UUID

    var body: some View {
        let statusTip = TapStatusTip()
        HStack(spacing: 12) {
            Button {
                cycleStatus()
                statusTip.invalidate(reason: .actionPerformed)
            } label: {
                Image(systemName: task.status.icon)
                    .foregroundStyle(statusColor)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .popoverTip(statusTip)
            .accessibilityLabel("Status: \(task.status.rawValue)")
            .accessibilityHint("Double tap to change status")

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(task.status == .completed, color: .secondary)

                HStack(spacing: 8) {
                    Text(task.dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(isDueSoon ? .red : .secondary)

                    Text(task.priority.rawValue)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
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
            }

            Spacer()
        }
        .padding(.vertical, 2)
        .accessibilityLabel("\(task.title), \(task.status.rawValue), \(task.priority.rawValue) priority\(task.recurrenceRule != .none ? ", repeats \(task.recurrenceRule.rawValue.lowercased())" : "")\(isDueSoon ? ", due soon" : "")\(!task.steps.isEmpty ? ", \(task.completedStepsCount) of \(task.steps.count) steps done" : "")")
    }

    private func cycleStatus() {
        store.pushUndo()
        let updated = task
        switch task.status {
        case .notStarted: updated.status = .inProgress
        case .inProgress: updated.status = .completed
        case .completed: updated.status = .notStarted
        }
        store.updateTask(updated, in: projectID)
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

    private var isDueSoon: Bool {
        task.status != .completed && task.dueDate < Calendar.current.date(byAdding: .day, value: 2, to: .now)!
    }
}
