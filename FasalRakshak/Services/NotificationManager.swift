//
//  NotificationManager.swift
//  FasalRakshak
//
//  Push notifications and reminder management with voice alerts
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized: Bool = false
    @Published var pendingNotifications: [UNNotificationRequest] = []

    private let notificationCenter = UNUserNotificationCenter.current()
    private let voiceAssistant = VoiceAssistantService.shared

    override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
            }

            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized ||
                                    settings.authorizationStatus == .provisional
            }
        }
    }

    // MARK: - Reminder Scheduling

    /// Schedule a crop reminder notification
    func scheduleReminder(_ reminder: CropReminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.titleHindi
        content.body = reminder.descriptionHindi
        content.sound = .default
        content.badge = 1

        // Add category for action buttons
        content.categoryIdentifier = "CROP_REMINDER"

        // Add user info for handling
        content.userInfo = [
            "reminderId": reminder.id.uuidString,
            "type": reminder.type.rawValue,
            "titleEnglish": reminder.title,
            "descriptionEnglish": reminder.description
        ]

        // Create trigger based on scheduled date
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.scheduledDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )

        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }

        // Schedule repeating notifications if needed
        if reminder.repeatInterval != .none {
            scheduleRepeatingReminders(reminder)
        }

        refreshPendingNotifications()
    }

    /// Schedule repeating notifications for a reminder
    private func scheduleRepeatingReminders(_ reminder: CropReminder) {
        let repeatCount: Int
        let interval: DateComponents

        switch reminder.repeatInterval {
        case .daily:
            repeatCount = 30 // Schedule 30 days ahead
            interval = DateComponents(day: 1)
        case .weekly:
            repeatCount = 12 // Schedule 12 weeks ahead
            interval = DateComponents(weekOfYear: 1)
        case .biweekly:
            repeatCount = 8 // Schedule 16 weeks ahead
            interval = DateComponents(weekOfYear: 2)
        case .monthly:
            repeatCount = 6 // Schedule 6 months ahead
            interval = DateComponents(month: 1)
        case .none:
            return
        }

        var currentDate = reminder.scheduledDate

        for i in 1...repeatCount {
            guard let nextDate = Calendar.current.date(byAdding: interval, to: currentDate) else {
                continue
            }
            currentDate = nextDate

            let content = UNMutableNotificationContent()
            content.title = reminder.titleHindi
            content.body = reminder.descriptionHindi
            content.sound = .default
            content.categoryIdentifier = "CROP_REMINDER"
            content.userInfo = [
                "reminderId": reminder.id.uuidString,
                "type": reminder.type.rawValue,
                "occurrence": i
            ]

            let triggerDate = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: nextDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            let request = UNNotificationRequest(
                identifier: "\(reminder.id.uuidString)_\(i)",
                content: content,
                trigger: trigger
            )

            notificationCenter.add(request) { error in
                if let error = error {
                    print("Failed to schedule repeating notification: \(error)")
                }
            }
        }
    }

    /// Cancel a scheduled reminder
    func cancelReminder(_ reminderId: UUID) {
        // Cancel main notification
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderId.uuidString])

        // Cancel all repeating notifications
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            let relatedIds = requests
                .filter { $0.identifier.starts(with: reminderId.uuidString) }
                .map { $0.identifier }

            self?.notificationCenter.removePendingNotificationRequests(withIdentifiers: relatedIds)
            self?.refreshPendingNotifications()
        }
    }

    /// Update an existing reminder
    func updateReminder(_ reminder: CropReminder) {
        cancelReminder(reminder.id)
        scheduleReminder(reminder)
    }

    // MARK: - Diagnosis Notifications

    /// Schedule a follow-up notification for diagnosis
    func scheduleFollowUpNotification(for diagnosis: DiagnosisResult, afterDays: Int = 3) {
        guard let followUpDate = Calendar.current.date(byAdding: .day, value: afterDays, to: Date()) else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "फसल जांच याद दिलाना"
        content.body = "अपनी फसल की फिर से जांच करें और प्रगति देखें।"
        content.sound = .default
        content.categoryIdentifier = "FOLLOWUP_DIAGNOSIS"
        content.userInfo = [
            "diagnosisId": diagnosis.id.uuidString,
            "type": "followup"
        ]

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: followUpDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: "followup_\(diagnosis.id.uuidString)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    // MARK: - Treatment Notifications

    /// Schedule treatment reminder
    func scheduleTreatmentReminder(treatment: Treatment, startDate: Date, diagnosisId: UUID) {
        let content = UNMutableNotificationContent()
        content.title = "उपचार याद दिलाना"
        content.body = "\(treatment.nameHindi) - \(treatment.applicationMethodHindi)"
        content.sound = .default
        content.categoryIdentifier = "TREATMENT_REMINDER"
        content.userInfo = [
            "treatmentId": treatment.id.uuidString,
            "diagnosisId": diagnosisId.uuidString,
            "type": "treatment"
        ]

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: startDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: "treatment_\(treatment.id.uuidString)_\(diagnosisId.uuidString)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    // MARK: - Notification Categories

    func setupNotificationCategories() {
        // Crop Reminder Category
        let markDoneAction = UNNotificationAction(
            identifier: "MARK_DONE",
            title: "पूर्ण करें",
            options: .foreground
        )
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "बाद में याद दिलाएं",
            options: []
        )
        let cropReminderCategory = UNNotificationCategory(
            identifier: "CROP_REMINDER",
            actions: [markDoneAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        // Follow-up Diagnosis Category
        let takePhotoAction = UNNotificationAction(
            identifier: "TAKE_PHOTO",
            title: "फोटो लें",
            options: .foreground
        )
        let followupCategory = UNNotificationCategory(
            identifier: "FOLLOWUP_DIAGNOSIS",
            actions: [takePhotoAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        // Treatment Reminder Category
        let viewTreatmentAction = UNNotificationAction(
            identifier: "VIEW_TREATMENT",
            title: "उपचार देखें",
            options: .foreground
        )
        let treatmentCategory = UNNotificationCategory(
            identifier: "TREATMENT_REMINDER",
            actions: [viewTreatmentAction, markDoneAction],
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([
            cropReminderCategory,
            followupCategory,
            treatmentCategory
        ])
    }

    // MARK: - Utility Methods

    func refreshPendingNotifications() {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            DispatchQueue.main.async {
                self?.pendingNotifications = requests
            }
        }
    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        refreshPendingNotifications()
    }

    func clearBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    /// Get number of scheduled notifications
    func getScheduledCount() -> Int {
        return pendingNotifications.count
    }

    /// Check if a specific reminder is scheduled
    func isReminderScheduled(_ reminderId: UUID) -> Bool {
        pendingNotifications.contains { $0.identifier.contains(reminderId.uuidString) }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification banner and play sound
        completionHandler([.banner, .sound, .badge])

        // Speak notification content if voice is enabled
        let content = notification.request.content
        voiceAssistant.speakHindi("\(content.title)। \(content.body)", priority: .high)
    }

    // Handle notification interaction
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case "MARK_DONE":
            handleMarkDone(userInfo: userInfo)

        case "SNOOZE":
            handleSnooze(notification: response.notification)

        case "TAKE_PHOTO":
            handleTakePhoto(userInfo: userInfo)

        case "VIEW_TREATMENT":
            handleViewTreatment(userInfo: userInfo)

        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification
            handleNotificationTap(userInfo: userInfo)

        default:
            break
        }

        completionHandler()
    }

    // MARK: - Action Handlers

    private func handleMarkDone(userInfo: [AnyHashable: Any]) {
        guard let reminderIdString = userInfo["reminderId"] as? String,
              let reminderId = UUID(uuidString: reminderIdString) else {
            return
        }

        // Mark reminder as completed in storage
        let offlineManager = OfflineDataManager.shared
        var reminders = offlineManager.getAllReminders()

        if let index = reminders.firstIndex(where: { $0.id == reminderId }) {
            var updatedReminder = reminders[index]
            updatedReminder.isCompleted = true
            try? offlineManager.saveReminder(updatedReminder)
        }

        // Speak confirmation
        voiceAssistant.speakHindi("कार्य पूर्ण के रूप में चिह्नित किया गया।")
    }

    private func handleSnooze(notification: UNNotification) {
        let content = notification.request.content

        // Reschedule for 1 hour later
        let newContent = content.mutableCopy() as! UNMutableNotificationContent

        let snoozeDate = Date().addingTimeInterval(3600) // 1 hour
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: snoozeDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: "\(notification.request.identifier)_snoozed",
            content: newContent,
            trigger: trigger
        )

        notificationCenter.add(request)
        voiceAssistant.speakHindi("एक घंटे बाद फिर से याद दिलाया जाएगा।")
    }

    private func handleTakePhoto(userInfo: [AnyHashable: Any]) {
        // Post notification to open camera
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenCameraForFollowUp"),
            object: nil,
            userInfo: userInfo
        )
    }

    private func handleViewTreatment(userInfo: [AnyHashable: Any]) {
        // Post notification to view treatment details
        NotificationCenter.default.post(
            name: NSNotification.Name("ViewTreatmentDetails"),
            object: nil,
            userInfo: userInfo
        )
    }

    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        // Handle based on notification type
        if let type = userInfo["type"] as? String {
            NotificationCenter.default.post(
                name: NSNotification.Name("NotificationTapped"),
                object: nil,
                userInfo: userInfo
            )
        }
    }
}
