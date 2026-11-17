import SwiftUI

// LociStoa redesign: the More tab.
// Planner shortcuts, the home screen widget switches, dark mode, common links,
// and the account (which school you are signed in to, and Sign out).

struct LSMoreScreen: View {
    @EnvironmentObject var store: LSStore
    @State private var showingClassic = false
    @State private var showingAdmin = false

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
                    LSCaps(text: "Home screen")
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
                                .tint(store.p.accentInk)
                                .frame(minHeight: 62)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // Display: dark mode keeps the school's colors on a dark background
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Display")
                    LSCard(padding: 0) {
                        Toggle(isOn: Binding(
                            get: { store.isDark },
                            set: { store.darkChoice = $0 }
                        )) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Dark mode").font(.ls(15, .semibold))
                                Text("Your school's colors on a dark background")
                                    .font(.ls(13))
                                    .foregroundStyle(store.p.sub)
                            }
                        }
                        .tint(store.p.accentInk)
                        .frame(minHeight: 62)
                        .padding(.horizontal, 16)
                    }
                }

                // Common links
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Common links")
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

                // The app as it was before the redesign, so nothing the team built is out of reach.
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Team builds")
                    LSCard(padding: 0) {
                        Group {
                            LSNavRow(title: "Classic dashboard", sub: "Live map, schedule, career fair, and the earlier screens") {
                                showingClassic = true
                            }
                            LSRule()
                            LSNavRow(title: "IT settings", sub: "The earlier admin screen, behind its PIN") {
                                showingAdmin = true
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // Account: the school comes from the email used to sign in
                VStack(alignment: .leading, spacing: 8) {
                    LSCaps(text: "Account")
                    LSCard(padding: 0) {
                        Group {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(store.school?.name ?? "").font(.ls(15, .semibold))
                                Text(store.user?.email ?? "")
                                    .font(.ls(13))
                                    .foregroundStyle(store.p.sub)
                            }
                            .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
                            LSRule()
                            Button {
                                store.signOut()
                            } label: {
                                Text("Sign out")
                                    .font(.ls(15, .semibold))
                                    .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(LSPressStyle())
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
                    Text("On the way: Ask LociStoa, dining hall hours, campus events, and a graduation checklist.")
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
        .sheet(isPresented: $showingAdmin) {
            AdminSettingsView()
        }
    }
}
