import SwiftUI

// LociStoa redesign: the More tab.
// Planner shortcuts, the home screen widget switches, color themes, common links,
// and what is still on the way.

struct LSMoreScreen: View {
    @EnvironmentObject var store: LSStore
    @State private var showingClassic = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                LSTitle(text: "More")

                // Planner
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Planner")
                    LSCard(padding: 0) {
                        Group {
                            LSNavRow(title: "My classes", sub: "Your class schedule") {
                                store.openPlanner(.times)
                            }
                            LSRule()
                            LSNavRow(title: "Tasks", sub: "Assignments and exams") {
                                store.openPlanner(.tasks)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // Home screen widgets
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Home screen · choose what you see")
                    LSCard(padding: 0) {
                        Group {
                            ForEach(Array(LSStore.widgetList.enumerated()), id: \.element.key) { index, widget in
                                if index > 0 {
                                    LSRule()
                                }
                                Toggle(isOn: Binding(
                                    get: { store.widgetOn(widget.key) },
                                    set: { _ in store.toggleWidget(widget.key) }
                                )) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(widget.label).font(.ls(15, .semibold))
                                        Text(widget.sub)
                                            .font(.ls(13))
                                            .foregroundStyle(store.p.sub)
                                    }
                                }
                                .tint(store.p.accent)
                                .frame(minHeight: 62)
                            }
                            LSRule()
                            LSSoonRow(title: "Dining hall hours", sub: "Needs a live source for hours")
                            LSRule()
                            LSSoonRow(title: "Campus events", sub: "Needs an events feed")
                            LSRule()
                            LSSoonRow(title: "Graduation checklist", sub: "For students in their final year")
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // Appearance
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Appearance")
                    HStack(spacing: 8) {
                        ForEach(LSPalette.all) { theme in
                            let on = store.themeID == theme.id
                            Button {
                                store.themeID = theme.id
                            } label: {
                                VStack(spacing: 7) {
                                    Circle()
                                        .fill(theme.accent)
                                        .frame(width: 28, height: 28)
                                    Text(theme.label).font(.ls(13, on ? .bold : .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(on ? store.p.accent : store.p.line, lineWidth: 2)
                                )
                            }
                            .buttonStyle(LSPressStyle())
                            .accessibilityAddTraits(on ? .isSelected : [])
                        }
                    }
                }

                // Common links
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Common links · open in your browser")
                    LSCard(padding: 0) {
                        ForEach(Array(store.data.links.enumerated()), id: \.element.id) { index, link in
                            if index > 0 {
                                LSRule()
                            }
                            if let url = URL(string: link.url) {
                                Link(destination: url) {
                                    HStack {
                                        Text(link.label).font(.ls(15, .semibold))
                                        Spacer(minLength: 0)
                                        Image(systemName: "arrow.up.right").font(.ls(14, .bold))
                                    }
                                    .foregroundStyle(store.p.ink)
                                    .frame(height: 56)
                                    .contentShape(Rectangle())
                                }
                                .accessibilityHint("Opens in browser")
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // On the way
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "On the way")
                    LSCard(padding: 0) {
                        Group {
                            LSSoonRow(title: "Ask LociStoa", sub: "Chatbot for campus questions")
                            LSRule()
                            LSSoonRow(title: "Career Fair", sub: "Built by another team")
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // The app as it was before the redesign, so nothing the team built is out of reach.
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Team builds")
                    LSCard(padding: 0) {
                        LSNavRow(title: "Classic dashboard", sub: "Live map, schedule, career fair, and the earlier screens") {
                            showingClassic = true
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // About
                VStack(alignment: .leading, spacing: 6) {
                    LSCaps(text: "About this build")
                    Text("Data loaded from the CSV files in the app's CampusData folder.")
                        .font(.ls(13))
                        .foregroundStyle(store.p.sub)
                    Text(store.data.summary)
                        .font(.ls(13))
                        .foregroundStyle(store.p.sub)
                }
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingClassic) {
            DashboardView()
        }
    }
}

/// A row for something that is not built yet.
struct LSSoonRow: View {
    @EnvironmentObject var store: LSStore
    let title: String
    let sub: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title).font(.ls(15, .semibold))
                Text(sub)
                    .font(.ls(13))
                    .foregroundStyle(store.p.sub)
            }
            Spacer(minLength: 0)
            Text("Coming soon")
                .font(.ls(12, .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(store.p.tint)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .frame(minHeight: 62)
    }
}
