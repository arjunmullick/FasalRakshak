//
//  HomeView.swift
//  FasalRakshak
//
//  Minimalist English-only home screen
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var offlineManager = OfflineDataManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared

    @State private var recentDiagnoses: [DiagnosisResult] = []
    @State private var navigateToCamera = false
    @State private var navigateToSymptoms = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Section
                        heroSection

                        // Quick Actions
                        quickActionsSection

                        // Recent Diagnoses
                        if !recentDiagnoses.isEmpty {
                            recentDiagnosesSection
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Crop Guardian")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ConnectionIndicator()
                }
            }
            .onAppear {
                loadRecentDiagnoses()
            }
            // Navigation Links (hidden)
            .background(
                NavigationLink(destination: CameraCaptureView(), isActive: $navigateToCamera) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(destination: SymptomCheckerView(), isActive: $navigateToSymptoms) {
                    EmptyView()
                }
            )
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detect & Protect")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("AI-powered crop disease detection at your fingertips")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            // Primary Action - Camera
            Button(action: {
                navigateToCamera = true
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scan Crop")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)

                        Text("Take photo for instant diagnosis")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(ScaleButtonStyle())

            // Secondary Actions
            HStack(spacing: 12) {
                // Symptoms Checker
                Button(action: {
                    navigateToSymptoms = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "list.bullet.clipboard.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.blue)

                        Text("Symptoms")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())

                // History
                NavigationLink(destination: DiagnosisHistoryView()) {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.purple)

                        Text("History")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    // MARK: - Recent Diagnoses

    private var recentDiagnosesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Scans")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                NavigationLink(destination: DiagnosisHistoryView()) {
                    Text("View All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
            }

            VStack(spacing: 12) {
                ForEach(recentDiagnoses.prefix(3)) { diagnosis in
                    NavigationLink(destination: DiagnosisDetailView(diagnosis: diagnosis)) {
                        MinimalDiagnosisCard(diagnosis: diagnosis)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    // MARK: - Data Loading

    private func loadRecentDiagnoses() {
        recentDiagnoses = offlineManager.getDiagnosisHistory()
    }
}

// MARK: - Minimal Diagnosis Card

struct MinimalDiagnosisCard: View {
    let diagnosis: DiagnosisResult

    var body: some View {
        HStack(spacing: 12) {
            // Health indicator
            ZStack {
                Circle()
                    .fill(healthColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: healthIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(healthColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(cropName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                Text(healthStatus)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)

                Text(timeAgo)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private var cropName: String {
        diagnosis.identifiedCrop?.name ?? "Unknown Crop"
    }

    private var healthStatus: String {
        let score = diagnosis.overallHealthScore
        switch score {
        case 80...100: return "Healthy"
        case 60..<80: return "Mildly Affected"
        case 40..<60: return "Moderately Affected"
        case 20..<40: return "Severely Affected"
        default: return "Critical"
        }
    }

    private var healthColor: Color {
        let score = diagnosis.overallHealthScore
        switch score {
        case 80...100: return .green
        case 60..<80: return .yellow
        case 40..<60: return .orange
        case 20..<40: return .red
        default: return .purple
        }
    }

    private var healthIcon: String {
        let score = diagnosis.overallHealthScore
        switch score {
        case 80...100: return "checkmark.circle.fill"
        case 60..<80: return "exclamationmark.circle.fill"
        case 40..<60: return "exclamationmark.triangle.fill"
        default: return "xmark.circle.fill"
        }
    }

    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: diagnosis.timestamp, relativeTo: Date())
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(AppState())
}
