import SwiftUI
import Observation

/// Pinned offices, people and orgs. Saved on the device, so pins stay after the app closes.
/// DirectoryView creates one and shares it with every page through `.environment`.
@Observable
final class PinStore {
    /// Newest first. Each key looks like "office:registrar", "person:p30" or "org:906-skate-crew".
    private(set) var keys: [String]

    private static let storageKey = "directory.pins"

    init() {
        keys = UserDefaults.standard.stringArray(forKey: Self.storageKey) ?? []
    }

    func isPinned(_ key: String) -> Bool {
        keys.contains(key)
    }

    /// Pins it if it isn't pinned, unpins it if it is.
    func toggle(_ key: String) {
        if let index = keys.firstIndex(of: key) {
            keys.remove(at: index)
        } else {
            keys.insert(key, at: 0)
        }
        UserDefaults.standard.set(keys, forKey: Self.storageKey)
    }

    var offices: [Office] {
        items(withPrefix: "office:") { DirectoryData.officeByID[$0] }
    }

    var people: [Person] {
        items(withPrefix: "person:") { DirectoryData.personByID[$0] }
    }

    var orgs: [Org] {
        items(withPrefix: "org:") { DirectoryData.orgBySlug[$0] }
    }

    /// Turns saved keys back into offices, people or orgs. Skips any that no longer exist in the data.
    private func items<T>(withPrefix prefix: String, find: (String) -> T?) -> [T] {
        keys.compactMap { key in
            key.hasPrefix(prefix) ? find(String(key.dropFirst(prefix.count))) : nil
        }
    }
}

/// The pin button at the top right of an office, person or org page.
struct PinButton: View {
    let key: String
    @Environment(PinStore.self) private var pins

    var body: some View {
        let pinned = pins.isPinned(key)
        Button {
            withAnimation {
                pins.toggle(key)
            }
        } label: {
            Image(systemName: pinned ? "pin.fill" : "pin")
        }
        .accessibilityLabel(pinned ? "Unpin" : "Pin")
        .sensoryFeedback(.selection, trigger: pinned)   // a small tap you feel on iPhone
    }
}

/// The dashed tip box shown in the Pinned section until something is pinned.
struct PinnedTip: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "pin")
                .foregroundStyle(lociAccent)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(lociAccent.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
        )
    }
}
