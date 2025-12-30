//
//  NetworkMonitor.swift
//  FasalRakshak
//
//  Network connectivity monitoring for offline mode detection
//

import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = true
    @Published var connectionType: ConnectionType = .unknown
    @Published var isExpensive: Bool = false // Cellular data
    @Published var isConstrained: Bool = false // Low data mode

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown

        var displayName: String {
            switch self {
            case .wifi: return "WiFi"
            case .cellular: return "Mobile Data"
            case .ethernet: return "Ethernet"
            case .unknown: return "Unknown"
            }
        }

        var displayNameHindi: String {
            switch self {
            case .wifi: return "वाईफाई"
            case .cellular: return "मोबाइल डेटा"
            case .ethernet: return "ईथरनेट"
            case .unknown: return "अज्ञात"
            }
        }
    }

    init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.isExpensive = path.isExpensive
                self?.isConstrained = path.isConstrained

                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.connectionType = .ethernet
                } else {
                    self?.connectionType = .unknown
                }

                // Notify about connection changes
                self?.notifyConnectionChange()
            }
        }

        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    private func notifyConnectionChange() {
        if !isConnected {
            // Notify user about offline mode
            NotificationCenter.default.post(
                name: NSNotification.Name("NetworkStatusChanged"),
                object: nil,
                userInfo: ["isConnected": false]
            )

            // Speak offline notification
            VoiceAssistantService.shared.speakHindi(
                VoiceAssistantService.VoiceMessages.offlineModeHindi,
                priority: .normal
            )
        } else {
            NotificationCenter.default.post(
                name: NSNotification.Name("NetworkStatusChanged"),
                object: nil,
                userInfo: ["isConnected": true]
            )
        }
    }

    /// Check if we should download large content
    func shouldDownloadLargeContent() -> Bool {
        return isConnected && !isConstrained && !isExpensive
    }

    /// Check if we can sync with server
    func canSync() -> Bool {
        return isConnected
    }

    /// Get connection quality description
    func getConnectionQuality() -> ConnectionQuality {
        if !isConnected {
            return .none
        } else if connectionType == .wifi && !isConstrained {
            return .good
        } else if connectionType == .cellular && !isConstrained {
            return .moderate
        } else {
            return .poor
        }
    }

    enum ConnectionQuality {
        case none
        case poor
        case moderate
        case good

        var displayName: String {
            switch self {
            case .none: return "No Connection"
            case .poor: return "Poor"
            case .moderate: return "Moderate"
            case .good: return "Good"
            }
        }

        var displayNameHindi: String {
            switch self {
            case .none: return "कोई कनेक्शन नहीं"
            case .poor: return "कमज़ोर"
            case .moderate: return "मध्यम"
            case .good: return "अच्छा"
            }
        }

        var color: String {
            switch self {
            case .none: return "red"
            case .poor: return "orange"
            case .moderate: return "yellow"
            case .good: return "green"
            }
        }
    }
}

// MARK: - Network Status View Component

import SwiftUI

struct NetworkStatusBanner: View {
    @ObservedObject var networkMonitor = NetworkMonitor.shared

    var body: some View {
        if !networkMonitor.isConnected {
            HStack {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.white)

                Text("ऑफलाइन मोड")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                Spacer()

                Text("कुछ सुविधाएं सीमित")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange)
        }
    }
}

struct ConnectionIndicator: View {
    @ObservedObject var networkMonitor = NetworkMonitor.shared

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 8, height: 8)

            if showText {
                Text(networkMonitor.connectionType.displayNameHindi)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var showText: Bool {
        networkMonitor.isConnected
    }

    private var indicatorColor: Color {
        switch networkMonitor.getConnectionQuality() {
        case .none:
            return .red
        case .poor:
            return .orange
        case .moderate:
            return .yellow
        case .good:
            return .green
        }
    }
}
