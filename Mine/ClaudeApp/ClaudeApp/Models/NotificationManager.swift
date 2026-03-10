import Foundation
import UserNotifications

@Observable
class NotificationManager: @unchecked Sendable {
    private(set) var isAuthorized = false

    private let center = UNUserNotificationCenter.current()

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                isAuthorized = granted
            }
        } catch {
            await MainActor.run {
                isAuthorized = false
            }
        }
    }

    func checkAuthorization() async {
        let settings = await center.notificationSettings()
        let authorized = settings.authorizationStatus == .authorized
        await MainActor.run {
            isAuthorized = authorized
        }
    }

    // MARK: - Scheduling

    /// Removes all pending notifications and reschedules based on current projects.
    func rescheduleAll(for projects: [Project]) async {
        center.removeAllPendingNotificationRequests()

        guard isAuthorized else { return }

        let calendar = Calendar.current
        let now = Date.now

        var badgeCount = 0

        for project in projects {
            // Schedule project end-date notifications
            if project.completionPercentage < 1.0 {
                // Due today notification (9 AM on the end date)
                if let dueTodayDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: project.endDate),
                   dueTodayDate > now {
                    let content = UNMutableNotificationContent()
                    content.title = "Project Due Today"
                    content.body = "\"\(project.name)\" is due today."
                    content.sound = .default

                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueTodayDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "project-due-\(project.id.uuidString)",
                        content: content,
                        trigger: trigger
                    )
                    try? await center.add(request)
                }

                // 5-day warning notification (9 AM, 5 days before end date)
                if let warningDate = calendar.date(byAdding: .day, value: -5, to: project.endDate),
                   let warningTriggerDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: warningDate),
                   warningTriggerDate > now {
                    let content = UNMutableNotificationContent()
                    content.title = "Project Due Soon"
                    content.body = "\"\(project.name)\" is due in 5 days."
                    content.sound = .default

                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: warningTriggerDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "project-warning-\(project.id.uuidString)",
                        content: content,
                        trigger: trigger
                    )
                    try? await center.add(request)
                }
            }

            // Schedule task notifications
            for task in project.tasks where task.status != .completed {
                // Due today notification (9 AM on the due date)
                if let dueTodayDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: task.dueDate),
                   dueTodayDate > now {
                    let content = UNMutableNotificationContent()
                    content.title = "Task Due Today"
                    content.body = "\"\(task.title)\" in \(project.name) is due today."
                    content.sound = .default

                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueTodayDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "task-due-\(task.id.uuidString)",
                        content: content,
                        trigger: trigger
                    )
                    try? await center.add(request)
                } else if calendar.isDateInToday(task.dueDate) {
                    // Task is due today but 9 AM already passed — count for badge
                    badgeCount += 1
                }

                // 5-day warning notification (9 AM, 5 days before due date)
                if let warningDate = calendar.date(byAdding: .day, value: -5, to: task.dueDate),
                   let warningTriggerDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: warningDate),
                   warningTriggerDate > now {
                    let content = UNMutableNotificationContent()
                    content.title = "Task Due Soon"
                    content.body = "\"\(task.title)\" in \(project.name) is due in 5 days."
                    content.sound = .default

                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: warningTriggerDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "task-warning-\(task.id.uuidString)",
                        content: content,
                        trigger: trigger
                    )
                    try? await center.add(request)
                }
            }
        }

        // Update badge with count of incomplete tasks due today or overdue
        let overdueTasks = projects.flatMap { $0.tasks }
            .filter { $0.status != .completed && calendar.startOfDay(for: $0.dueDate) <= calendar.startOfDay(for: now) }
        badgeCount = overdueTasks.count
        updateBadge(count: badgeCount)
    }

    // MARK: - Badge

    func updateBadge(count: Int) {
        try? center.setBadgeCount(count)
    }

    func clearBadge() {
        try? center.setBadgeCount(0)
    }
}
