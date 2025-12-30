//
//  DiagnosisHistoryView.swift
//  FasalRakshak
//
//  Farmer dashboard showing diagnosis history and trends
//

import SwiftUI

struct DiagnosisHistoryView: View {
    @EnvironmentObject var offlineManager: OfflineDataManager
    @EnvironmentObject var voiceAssistant: VoiceAssistantService

    @State private var diagnoses: [DiagnosisResult] = []
    @State private var selectedFilter: HistoryFilter = .all
    @State private var searchText = ""
    @State private var showingExportOptions = false

    enum HistoryFilter: String, CaseIterable {
        case all = "सभी"
        case healthy = "स्वस्थ"
        case diseased = "प्रभावित"
        case thisWeek = "इस सप्ताह"
        case thisMonth = "इस महीने"
    }

    var filteredDiagnoses: [DiagnosisResult] {
        var results = diagnoses

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .healthy:
            results = results.filter { $0.healthStatus == .healthy }
        case .diseased:
            results = results.filter { $0.healthStatus != .healthy }
        case .thisWeek:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            results = results.filter { $0.timestamp >= weekAgo }
        case .thisMonth:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            results = results.filter { $0.timestamp >= monthAgo }
        }

        // Apply search
        if !searchText.isEmpty {
            results = results.filter { diagnosis in
                if let crop = diagnosis.identifiedCrop {
                    return crop.name.localizedCaseInsensitiveContains(searchText) ||
                           crop.nameHindi.contains(searchText)
                }
                return diagnosis.diagnosedConditions.contains { condition in
                    condition.conditionName.localizedCaseInsensitiveContains(searchText) ||
                    condition.conditionNameHindi.contains(searchText)
                }
            }
        }

        return results
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Stats summary
                statsSummary

                // Filter chips
                filterChips

                // Search bar
                searchBar

                // Diagnosis list
                if filteredDiagnoses.isEmpty {
                    emptyStateView
                } else {
                    diagnosisList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("जांच इतिहास")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingExportOptions = true }) {
                            Label("रिपोर्ट निर्यात करें", systemImage: "square.and.arrow.up")
                        }
                        Button(action: { speakSummary() }) {
                            Label("सारांश सुनें", systemImage: "speaker.wave.2")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                loadDiagnoses()
            }
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsView(diagnoses: filteredDiagnoses)
            }
        }
    }

    // MARK: - Stats Summary

    private var statsSummary: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                StatCard(
                    title: "कुल जांच",
                    value: "\(diagnoses.count)",
                    icon: "doc.text.magnifyingglass",
                    color: .blue
                )

                StatCard(
                    title: "स्वस्थ",
                    value: "\(diagnoses.filter { $0.healthStatus == .healthy }.count)",
                    icon: "checkmark.circle",
                    color: .green
                )

                StatCard(
                    title: "प्रभावित",
                    value: "\(diagnoses.filter { $0.healthStatus != .healthy }.count)",
                    icon: "exclamationmark.triangle",
                    color: .orange
                )

                StatCard(
                    title: "औसत स्वास्थ्य",
                    value: String(format: "%.0f%%", averageHealthScore),
                    icon: "heart",
                    color: healthScoreColor
                )
            }
            .padding()
        }
    }

    private var averageHealthScore: Double {
        guard !diagnoses.isEmpty else { return 100 }
        return diagnoses.reduce(0) { $0 + $1.overallHealthScore } / Double(diagnoses.count)
    }

    private var healthScoreColor: Color {
        switch averageHealthScore {
        case 80...100: return .green
        case 60..<80: return .yellow
        case 40..<60: return .orange
        default: return .red
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(HistoryFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("फसल या बीमारी खोजें", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Diagnosis List

    private var diagnosisList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredDiagnoses) { diagnosis in
                    NavigationLink(destination: DiagnosisDetailView(diagnosis: diagnosis)) {
                        DiagnosisHistoryCard(diagnosis: diagnosis)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("कोई जांच नहीं मिली")
                .font(.title2)
                .fontWeight(.semibold)

            Text("अपनी फसल की फोटो लेकर जांच शुरू करें")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                NotificationCenter.default.post(
                    name: NSNotification.Name("NavigateToCamera"),
                    object: nil
                )
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("फोटो लें")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.primaryGreen)
                .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Data Loading

    private func loadDiagnoses() {
        diagnoses = offlineManager.getDiagnosisHistory()
    }

    private func speakSummary() {
        let healthyCount = diagnoses.filter { $0.healthStatus == .healthy }.count
        let affectedCount = diagnoses.count - healthyCount

        let summary = """
        आपका जांच सारांश। कुल \(diagnoses.count) जांच की गई।
        \(healthyCount) फसलें स्वस्थ पाई गईं।
        \(affectedCount) फसलें प्रभावित पाई गईं।
        औसत स्वास्थ्य स्कोर \(Int(averageHealthScore)) प्रतिशत है।
        """
        voiceAssistant.speakHindi(summary)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)

                Spacer()
            }

            HStack {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()
            }

            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
        }
        .frame(width: 120)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primaryGreen : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Diagnosis History Card

struct DiagnosisHistoryCard: View {
    let diagnosis: DiagnosisResult

    var body: some View {
        HStack(spacing: 16) {
            // Image
            if let imageData = diagnosis.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    )
            }

            // Details
            VStack(alignment: .leading, spacing: 6) {
                // Crop and date
                HStack {
                    Text(diagnosis.identifiedCrop?.nameHindi ?? "फसल जांच")
                        .font(.headline)

                    Spacer()

                    Text(formatDate(diagnosis.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Health status
                HStack(spacing: 6) {
                    Image(systemName: diagnosis.healthStatus.icon)
                        .font(.caption)
                        .foregroundColor(diagnosis.healthStatus.color)

                    Text(diagnosis.healthStatus.displayNameHindi)
                        .font(.subheadline)
                        .foregroundColor(diagnosis.healthStatus.color)

                    Spacer()

                    // Health score
                    Text("\(Int(diagnosis.overallHealthScore))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(diagnosis.healthStatus.color)
                }

                // Conditions found
                if !diagnosis.diagnosedConditions.isEmpty {
                    HStack {
                        ForEach(diagnosis.diagnosedConditions.prefix(2)) { condition in
                            Text(condition.conditionNameHindi)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(condition.severity.color.opacity(0.1))
                                .foregroundColor(condition.severity.color)
                                .cornerRadius(8)
                        }

                        if diagnosis.diagnosedConditions.count > 2 {
                            Text("+\(diagnosis.diagnosedConditions.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "hi_IN")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Export Options View

struct ExportOptionsView: View {
    let diagnoses: [DiagnosisResult]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("निर्यात विकल्प")) {
                    Button(action: { exportAsPDF() }) {
                        Label("PDF रिपोर्ट", systemImage: "doc.richtext")
                    }

                    Button(action: { shareReport() }) {
                        Label("रिपोर्ट साझा करें", systemImage: "square.and.arrow.up")
                    }

                    Button(action: { exportToExcel() }) {
                        Label("Excel फाइल", systemImage: "tablecells")
                    }
                }

                Section(header: Text("जानकारी")) {
                    HStack {
                        Text("कुल जांच")
                        Spacer()
                        Text("\(diagnoses.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("अवधि")
                        Spacer()
                        Text(dateRange)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("रिपोर्ट निर्यात")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("बंद करें") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var dateRange: String {
        guard let first = diagnoses.last?.timestamp,
              let last = diagnoses.first?.timestamp else {
            return "N/A"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "hi_IN")
        formatter.dateStyle = .short
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }

    private func exportAsPDF() {
        // Generate PDF report
        dismiss()
    }

    private func shareReport() {
        // Share report
        dismiss()
    }

    private func exportToExcel() {
        // Export to CSV/Excel
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    DiagnosisHistoryView()
        .environmentObject(OfflineDataManager.shared)
        .environmentObject(VoiceAssistantService.shared)
}
