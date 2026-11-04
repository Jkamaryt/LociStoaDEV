import SwiftUI

/// The sliding row of emergency numbers at the top of the Offices tab.
/// Swipe sideways to see them all; tap a card to call.
/// To add or change a number, edit `emergencyNumbers` in DirectoryData.swift.
struct EmergencySlider: View {
    private let numbers = DirectoryData.emergencyNumbers

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("In an emergency", systemImage: "exclamationmark.triangle.fill")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(.red)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(numbers) { item in
                        EmergencyCard(item: item)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 20, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)   // cards snap into place as you swipe
        }
    }
}

struct EmergencyCard: View {
    let item: EmergencyNumber
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            if let url = item.dialURL { openURL(url) }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(item.isPrimary ? Color.white : Color.primary)
                    .lineLimit(1)

                Text(item.number)
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                    .foregroundStyle(item.isPrimary ? Color.white : Color.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(item.isPrimary ? Color.white.opacity(0.85) : Color.secondary)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 150, alignment: .leading)
            .padding(14)
            .background(item.isPrimary ? Color.red : Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Call \(item.name), \(item.number)")
    }
}
