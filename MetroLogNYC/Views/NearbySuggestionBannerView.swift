import SwiftUI

/// Floating banner that suggests marking a nearby station as visited
struct NearbySuggestionBannerView: View {
    let item: StationDisplayItem
    let onMarkVisited: () -> Void
    let onDismiss: () -> Void

    @State private var isVisible = false

    private func dismissWithAnimation(then action: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 0.25)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            action()
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Location icon
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("You're near")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(item.name)
                        .font(.headline)
                        .lineLimit(2)

                    // Line badges
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(item.lines.prefix(8), id: \.self) { line in
                                LineBadge(line: line, size: 20)
                            }
                            if item.lines.count > 8 {
                                Text("+\(item.lines.count - 8)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Action buttons
            HStack(spacing: 12) {
                Button {
                    dismissWithAnimation(then: onDismiss)
                } label: {
                    Text("Not Now")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    dismissWithAnimation(then: onMarkVisited)
                } label: {
                    Text("Mark Visited")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
        .offset(y: isVisible ? 0 : 300)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        VStack {
            Spacer()
            NearbySuggestionBannerView(
                item: PreviewData.sampleDisplayItem,
                onMarkVisited: {},
                onDismiss: {}
            )
            .padding(.bottom, 100)
        }
    }
}

// Preview helper
private enum PreviewData {
    static var sampleDisplayItem: StationDisplayItem {
        // Create a mock station for preview
        let station = Station(
            name: "Times Sq-42 St",
            lines: [.one, .two, .three, .seven, .n, .q, .r, .w],
            latitude: 40.7559,
            longitude: -73.9871,
            borough: .manhattan
        )
        return StationDisplayItem(station: station)
    }
}
