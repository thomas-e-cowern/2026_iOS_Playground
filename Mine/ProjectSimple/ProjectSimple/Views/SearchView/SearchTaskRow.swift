//
//  SearchTaskRow.swift
//  ProjectSimple
//
//  Created by Thomas Cowern on 3/17/26.
//

import Foundation
import SwiftUI

// MARK: - Search Task Row

struct SearchTaskRow: View {
    let task: ProjectTask
    let projectName: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.status.icon)
                .foregroundStyle(statusColor)
                .font(.title3)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                
                HStack(spacing: 8) {
                    Text(projectName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(task.priority.rawValue)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priorityColor.opacity(0.15))
                        .foregroundStyle(priorityColor)
                        .clipShape(Capsule())
                    
                    Text(task.dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(projectName), \(task.status.rawValue), \(task.priority.rawValue) priority\(task.recurrenceRule != .none ? ", repeats \(task.recurrenceRule.rawValue.lowercased())" : "")\(!task.steps.isEmpty ? ", \(task.completedStepsCount) of \(task.steps.count) steps done" : "")")
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
}
