//
//  CropViews.swift
//  FasalRakshak
//
//  Crop selection and detail views
//

import SwiftUI

// MARK: - Crop Selector View

struct CropSelectorView: View {
    @Binding var selectedCrop: Crop?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var offlineManager: OfflineDataManager

    @State private var searchText = ""
    @State private var selectedCategory: CropCategory?

    var filteredCrops: [Crop] {
        var crops = offlineManager.getAllCrops()

        if let category = selectedCategory {
            crops = crops.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            crops = crops.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.nameHindi.contains(searchText)
            }
        }

        return crops
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("फसल खोजें", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()

                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryChip(
                            title: "सभी",
                            icon: "square.grid.2x2",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }

                        ForEach(CropCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.displayNameHindi,
                                icon: nil,
                                emoji: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)

                // Crop list
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredCrops) { crop in
                            CropGridItem(
                                crop: crop,
                                isSelected: selectedCrop?.id == crop.id
                            ) {
                                selectedCrop = crop
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("फसल चुनें")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("बंद करें") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let icon: String?
    var emoji: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let emoji = emoji {
                    Text(emoji)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primaryGreen : Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

// MARK: - Crop Grid Item

struct CropGridItem: View {
    let crop: Crop
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(crop.category.icon)
                    .font(.title)

                Text(crop.nameHindi)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.primaryGreen.opacity(0.15) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryGreen : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Crop Category View

struct CropCategoryView: View {
    let category: CropCategory
    @EnvironmentObject var offlineManager: OfflineDataManager

    var crops: [Crop] {
        offlineManager.getCropsByCategory(category)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Category header
                VStack(spacing: 8) {
                    Text(category.icon)
                        .font(.system(size: 60))

                    Text(category.displayNameHindi)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(category.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGreen.opacity(0.1))
                .cornerRadius(16)

                // Crops list
                ForEach(crops) { crop in
                    NavigationLink(destination: CropDetailView(crop: crop)) {
                        CropListRow(crop: crop)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(category.displayNameHindi)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Crop List Row

struct CropListRow: View {
    let crop: Crop

    var body: some View {
        HStack(spacing: 16) {
            Text(crop.category.icon)
                .font(.title)
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(crop.nameHindi)
                    .font(.headline)

                Text(crop.scientificName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()

                HStack {
                    ForEach(crop.season.prefix(2), id: \.self) { season in
                        Text(season.displayNameHindi)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Crop Detail View

struct CropDetailView: View {
    let crop: Crop
    @EnvironmentObject var offlineManager: OfflineDataManager
    @EnvironmentObject var voiceAssistant: VoiceAssistantService

    var diseases: [Disease] {
        offlineManager.getDiseasesForCrop(crop.id.uuidString)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                cropHeader

                // Description
                descriptionSection

                // Growing info
                growingInfoSection

                // Common diseases
                if !diseases.isEmpty {
                    diseasesSection
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(crop.nameHindi)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: speakCropInfo) {
                    Image(systemName: "speaker.wave.2.fill")
                }
            }
        }
    }

    private var cropHeader: some View {
        VStack(spacing: 16) {
            Text(crop.category.icon)
                .font(.system(size: 80))

            VStack(spacing: 4) {
                Text(crop.nameHindi)
                    .font(.title)
                    .fontWeight(.bold)

                Text(crop.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(crop.scientificName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }

            // Category badge
            Text(crop.category.displayNameHindi)
                .font(.caption)
                .foregroundColor(.primaryGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.primaryGreen.opacity(0.1))
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("विवरण")
                .font(.headline)

            Text(crop.descriptionHindi)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    private var growingInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("उगाने की जानकारी")
                .font(.headline)

            // Seasons
            InfoRow(
                icon: "calendar",
                title: "मौसम",
                content: crop.season.map { $0.displayNameHindi }.joined(separator: ", ")
            )

            // Water requirement
            InfoRow(
                icon: "drop.fill",
                title: "पानी की आवश्यकता",
                content: crop.waterRequirement.displayNameHindi
            )

            // Soil types
            InfoRow(
                icon: "mountain.2.fill",
                title: "मिट्टी के प्रकार",
                content: crop.soilType.map { $0.displayNameHindi }.joined(separator: ", ")
            )

            // Regions
            InfoRow(
                icon: "map.fill",
                title: "क्षेत्र",
                content: crop.regions.map { $0.displayNameHindi }.joined(separator: ", ")
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    private var diseasesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("सामान्य रोग और कीट")
                .font(.headline)

            ForEach(diseases.prefix(5)) { disease in
                NavigationLink(destination: DiseaseDetailView(disease: disease)) {
                    DiseaseListRow(disease: disease)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    private func speakCropInfo() {
        var speech = "\(crop.nameHindi)। \(crop.descriptionHindi)। "
        speech += "मौसम: \(crop.season.map { $0.displayNameHindi }.joined(separator: ", "))। "
        speech += "पानी की आवश्यकता: \(crop.waterRequirement.displayNameHindi)।"
        voiceAssistant.speakHindi(speech)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let title: String
    let content: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primaryGreen)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(content)
                    .font(.subheadline)
            }
        }
    }
}

// MARK: - Disease List Row

struct DiseaseListRow: View {
    let disease: Disease

    var body: some View {
        HStack(spacing: 12) {
            Text(disease.type.icon)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(disease.nameHindi)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(disease.type.displayNameHindi)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Severity indicator
            Text(disease.severity.displayNameHindi)
                .font(.caption2)
                .foregroundColor(disease.severity.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(disease.severity.color.opacity(0.1))
                .cornerRadius(8)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Previews

#Preview("Crop Selector") {
    CropSelectorView(selectedCrop: .constant(nil))
        .environmentObject(OfflineDataManager.shared)
}

#Preview("Crop Category") {
    NavigationView {
        CropCategoryView(category: .cereals)
            .environmentObject(OfflineDataManager.shared)
    }
}
