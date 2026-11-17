import SwiftUI

// LociStoa redesign: the frame around every screen.
// It shows the current tab's screen, the tab bar at the bottom, and anything that sits
// on top of the app (the slide-up panels, the "Marked done" message, the call confirmation).

struct LSRootView: View {
    @StateObject private var store = LSStore()
    @Environment(\.colorScheme) private var colorScheme

    /// Light or dark for the system's own pieces (keyboard, time pickers).
    /// nil means "follow the phone", which is also how we learn what the phone is set to.
    private var scheme: ColorScheme? {
        if store.user == nil {
            return .light               // the sign-in screen is always light
        }
        if let choice = store.darkChoice {
            return choice ? .dark : .light
        }
        return nil
    }

    var body: some View {
        Group {
            if store.user == nil {
                LSSignInScreen()
            } else {
                app
            }
        }
        .environmentObject(store)
        .preferredColorScheme(scheme)
        .onAppear {
            store.systemDark = colorScheme == .dark
        }
        .onChange(of: colorScheme) {
            store.systemDark = colorScheme == .dark
        }
    }

    /// The app itself, shown once someone is signed in.
    private var app: some View {
        ZStack(alignment: .bottom) {
            store.p.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch store.tab {
                    case .home:
                        LSHomeScreen()
                    case .people, .help:
                        LSPeopleHelpScreen()
                    case .map:
                        LSMapScreen()
                    case .planner:
                        LSPlannerScreen()
                    case .more:
                        LSMoreScreen()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if store.tab == .home {
                    LSHomeSearchBar()
                }
                LSTabBar()
            }

            if let toast = store.toast {
                LSToastView(toast: toast)
                    .padding(.horizontal, 20)
                    .padding(.bottom, store.tab == .home ? 150 : 76)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.25), value: store.toast)
        .foregroundStyle(store.p.ink)
        .tint(store.p.accentInk)
        .sheet(item: $store.sheet) { sheet in
            LSSheetHost(sheet: sheet)
                .environmentObject(store)
        }
        .modifier(LSCallConfirm(number: $store.confirmNumber))
    }
}

// MARK: - Tab bar

struct LSTabBar: View {
    @EnvironmentObject var store: LSStore

    private let tabs: [(tab: LSTab, label: String, icon: String)] = [
        (.home, "Home", "house"),
        (.people, "People", "person.2"),
        (.help, "Help", "questionmark.circle"),
        (.map, "Map", "map"),
        (.more, "More", "square.grid.2x2"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.label) { item in
                // The planner lives under More, so More stays lit while the planner is open.
                let on = store.tab == item.tab || (item.tab == .more && store.tab == .planner)
                Button {
                    store.go(item.tab)
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: item.icon)
                            .font(.ls(20, on ? .bold : .regular))
                            .frame(height: 24)
                        Text(item.label)
                            .font(.ls(11, on ? .bold : .semibold))
                    }
                    .foregroundStyle(on ? store.p.navOn : store.p.navSub)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(LSPressStyle())
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(.horizontal, 6)
        .background(store.p.navBg.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle().fill(store.p.navLine).frame(height: 1)
        }
    }
}

/// The search button pinned above the tab bar on the home screen.
struct LSHomeSearchBar: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        Button {
            store.openSearch()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.ls(19, .bold))
                    .foregroundStyle(store.p.ink)
                Text("Search people, places, and tools")
                    .font(.ls(16))
                    .foregroundStyle(store.p.sub)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(store.p.card)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(store.p.ink, lineWidth: 2))
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 8)
        }
        .buttonStyle(LSPressStyle())
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }
}

// MARK: - "Marked done" message

struct LSToastView: View {
    @EnvironmentObject var store: LSStore
    let toast: LSToast

    var body: some View {
        HStack {
            Text(toast.text).font(.ls(14, .semibold))
            Spacer(minLength: 0)
            Button {
                store.undoToast()
            } label: {
                Text("Undo")
                    .font(.ls(14, .bold))
                    .underline()
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .contentShape(Rectangle())
            }
        }
        .foregroundStyle(store.p.onDeep)
        .padding(.leading, 16)
        .padding(.trailing, 6)
        .frame(height: 52)
        .background(store.p.deep)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 10)
    }
}

// MARK: - Call confirmation

/// Asks "Call 911?" before anything happens. Tapping a number never calls straight away.
struct LSCallConfirm: ViewModifier {
    @Binding var number: LSNumber?

    func body(content: Content) -> some View {
        content.alert(
            "Call \(number?.number ?? "")?",
            isPresented: Binding(
                get: { number != nil },
                set: { showing in
                    if !showing { number = nil }
                }
            )
        ) {
            Button("Cancel", role: .cancel) { }
            Button("Call") { }
        } message: {
            Text("\(number?.label ?? "")\nCalls are turned off in this prototype.")
        }
    }
}

// MARK: - Slide-up panels

/// Picks which panel to show for store.sheet.
struct LSSheetHost: View {
    @EnvironmentObject var store: LSStore
    let sheet: LSSheet

    var body: some View {
        Group {
            switch sheet {
            case .emergency:
                LSEmergencySheet()
                    .presentationDetents([.medium, .large])
            case .contact:
                LSContactSheet()
                    .presentationDetents([.medium, .large])
            case .addTask:
                LSAddTaskSheet()
                    .presentationDetents([.medium, .large])
            case .addClass:
                LSAddClassSheet()
                    .presentationDetents([.large])
            case .search:
                LSSearchSheet()
                    .presentationDetents([.large])
            }
        }
        .presentationDragIndicator(.visible)
        .foregroundStyle(store.p.ink)
        .tint(store.p.accentInk)
    }
}

/// The title row at the top of a panel, with a round close button.
struct LSSheetHeader: View {
    @EnvironmentObject var store: LSStore
    let title: String

    var body: some View {
        HStack {
            Text(title).font(.ls(24, .heavy))
            Spacer(minLength: 0)
            LSCloseButton()
        }
    }
}

struct LSCloseButton: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        Button {
            store.sheet = nil
        } label: {
            Image(systemName: "xmark")
                .font(.ls(15, .bold))
                .frame(width: 44, height: 44)
                .background(store.p.tint)
                .clipShape(Circle())
        }
        .buttonStyle(LSPressStyle())
        .accessibilityLabel("Close")
    }
}
