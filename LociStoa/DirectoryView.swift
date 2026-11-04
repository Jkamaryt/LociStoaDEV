import SwiftUI

/// The Directory Contacts screen, opened from the dashboard button in ContentView.swift.
/// Three tabs: Offices and People (built), Orgs (coming next).
struct DirectoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tab: DirectoryTab = .offices
    @State private var query = ""

    var body: some View {
        NavigationStack {
            ZStack {
                lociBackground.ignoresSafeArea()

                VStack(spacing: 12) {
                    Picker("Section", selection: $tab) {
                        ForEach(DirectoryTab.allCases) { section in
                            Text(section.title).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)

                    switch tab {
                    case .offices:
                        OfficesTab(query: query)
                    case .people:
                        PeopleTab(query: query)
                    case .orgs:
                        ComingSoonTab(title: tab.title)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("Directory")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: tab.searchPrompt)
            #else
            .searchable(text: $query, prompt: tab.searchPrompt)
            #endif
            .onChange(of: tab) {
                query = ""   // each tab starts with an empty search
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

/// The three sections at the top of the Directory.
nonisolated enum DirectoryTab: String, CaseIterable, Identifiable {
    case offices, people, orgs

    var id: String { rawValue }

    var title: String {
        switch self {
        case .offices: return "Offices"
        case .people: return "People"
        case .orgs: return "Orgs"
        }
    }

    var searchPrompt: String {
        switch self {
        case .offices: return "Search offices or what you need"
        case .people: return "Search names, departments, titles"
        case .orgs: return "Search clubs and interests"
        }
    }
}

/// Placeholder for the tabs we haven't built in Swift yet.
struct ComingSoonTab: View {
    let title: String

    var body: some View {
        ContentUnavailableView(
            "\(title) coming soon",
            systemImage: "hammer",
            description: Text("This tab is the next piece we’re building.")
        )
        .frame(maxHeight: .infinity)
    }
}
