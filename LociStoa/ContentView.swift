import SwiftUI

let lociBackground = Color(red: 0.85, green: 0.85, blue: 1.0)
let lociAccent = Color(red: 0.45, green: 0.31, blue: 0.76)

struct ContentView: View {
    @StateObject private var store = LociStoaStore()
    
    var body: some View {
        Group {
            if store.isLoggedIn {
                DashboardView(store: store)
            } else {
                LoginView(isLoggedIn: $store.isLoggedIn, store: store)
            }
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $store.showingAdminSettings) {
            AdminSettingsView(store: store)
        }
    }
}

// MARK: - 1. Login View (Original LociStoa Login Features Styled in the Gavin UI Template)
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @ObservedObject var store: LociStoaStore
    
    @State private var username = ""
    @State private var password = ""
    
    private var theme: LociTheme { store.theme }
    
    var body: some View {
        ZStack {
            store.effectiveBgColor.ignoresSafeArea()
            
            VStack(spacing: 22) {
                // Top-Right Bypass Button
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            isLoggedIn = true
                        }
                    }) {
                        Text("Bypass")
                            .font(LociFont.sans(14, weight: .bold))
                            .foregroundColor(theme.ink)
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(theme.strong, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(LociPressButtonStyle())
                }
                
                Spacer()
                
                // Brand Header
                VStack(spacing: 6) {
                    Text("MICHIGAN TECH")
                        .font(LociFont.sans(12, weight: .bold))
                        .tracking(1.1)
                        .foregroundColor(theme.word)
                    
                    Text("LociStoa")
                        .font(LociFont.display(46, weight: .heavy))
                        .tracking(-0.9)
                        .foregroundColor(theme.ink)
                    
                    Text("Your Campus, Simplified")
                        .font(LociFont.sans(16, weight: .semibold))
                        .foregroundColor(theme.sub)
                }
                .padding(.bottom, 6)
                
                // Login Card (Gavin UI Card Style)
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("USERNAME")
                            .font(LociFont.sans(11.5, weight: .bold))
                            .tracking(0.96)
                            .foregroundColor(theme.sub)
                        
                        TextField("Username", text: $username)
                            .font(LociFont.sans(16))
                            .foregroundColor(theme.ink)
                            .padding(.horizontal, 14)
                            .frame(height: 52)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(theme.strong, lineWidth: 1.5)
                            )
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            #endif
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PASSWORD")
                            .font(LociFont.sans(11.5, weight: .bold))
                            .tracking(0.96)
                            .foregroundColor(theme.sub)
                        
                        SecureField("Password", text: $password)
                            .font(LociFont.sans(16))
                            .foregroundColor(theme.ink)
                            .padding(.horizontal, 14)
                            .frame(height: 52)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(theme.strong, lineWidth: 1.5)
                            )
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            isLoggedIn = true
                        }
                    }) {
                        Text("Sign In")
                            .font(LociFont.sans(16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(store.effectiveAccentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                    .padding(.top, 4)
                    
                    HStack {
                        Rectangle().fill(theme.rule).frame(height: 1)
                        Text("OR")
                            .font(LociFont.sans(12, weight: .bold))
                            .foregroundColor(theme.sub)
                            .padding(.horizontal, 8)
                        Rectangle().fill(theme.rule).frame(height: 1)
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            isLoggedIn = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("Sign in with Google")
                                .font(LociFont.sans(15, weight: .bold))
                        }
                        .foregroundColor(theme.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(theme.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            isLoggedIn = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("University SSO Sign-in")
                                .font(LociFont.sans(15, weight: .bold))
                        }
                        .foregroundColor(theme.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(theme.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(LociPressButtonStyle())
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
                
                Spacer()
                
                // Bottom-Right Admin Settings Gear Button
                HStack {
                    // Quick Theme Swatch Dots on Login
                    HStack(spacing: 8) {
                        ForEach(LociTheme.allCases) { t in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    store.theme = t
                                    store.customPrimaryBgColor = nil
                                    store.customSecondaryAccentColor = nil
                                }
                            }) {
                                Circle()
                                    .fill(t.swatch)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: store.theme == t ? 2.5 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        store.showingAdminSettings = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle().stroke(theme.line, lineWidth: 1)
                                )
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(theme.ink)
                        }
                    }
                    .buttonStyle(LociPressButtonStyle())
                    .accessibilityLabel("IT Administrator Settings")
                }
            }
            .padding(24)
        }
    }
}

// MARK: - 2. Dashboard View (Gavin HTML Edition UI + All Original LociStoa Features)
struct DashboardView: View {
    @ObservedObject var store: LociStoaStore
    
    private var theme: LociTheme { store.theme }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            store.effectiveBgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main Scrollable Content Area
                ScrollView(showsIndicators: false) {
                    Group {
                        switch store.tab {
                        case .home:
                            GavinHomeTabView(store: store)
                        case .people:
                            GavinPeopleTabView(store: store)
                        case .map:
                            GavinMapTabView(store: store)
                        case .planner:
                            GavinPlannerTabView(store: store)
                        case .more:
                            GavinMoreTabView(store: store)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Pinned Bottom Search Bar (Visible on Home tab)
                if store.tab == .home {
                    VStack(spacing: 0) {
                        Button(action: {
                            store.query = ""
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                                store.sheet = .search
                            }
                        }) {
                            HStack(spacing: 10) {
                                LociIcon(kind: .search, size: 22, lineWidth: 2.2, color: theme.ink)
                                Text("Search people, places, and tools")
                                    .font(LociFont.sans(16, weight: .regular))
                                    .foregroundColor(theme.sub)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(theme.ink, lineWidth: 2)
                            )
                            .shadow(color: Color(hex: 0x2B1F52, opacity: 0.12), radius: 10, x: 0, y: 8)
                        }
                        .buttonStyle(LociPressButtonStyle())
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .background(store.effectiveBgColor)
                }
                
                // Bottom Navigation Tab Bar (Matches <nav aria-label="Main"> in Main.dc.html)
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(theme.line)
                        .frame(height: 1)
                    
                    HStack(spacing: 0) {
                        ForEach(GavinTab.allCases) { tabItem in
                            let isCurrent = (store.tab == tabItem)
                            let itemColor = isCurrent ? store.effectiveAccentColor : theme.sub
                            
                            Button(action: {
                                store.go(tabItem)
                            }) {
                                VStack(spacing: 3) {
                                    LociIcon(
                                        kind: tabItem.iconKind,
                                        size: 24,
                                        lineWidth: 2.0,
                                        color: itemColor
                                    )
                                    Text(tabItem.label)
                                        .font(LociFont.sans(11, weight: isCurrent ? .bold : .semibold))
                                        .foregroundColor(itemColor)
                                }
                                .padding(.top, 4)
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 12)
                    .background(Color.white.ignoresSafeArea(edges: .bottom))
                }
            }
            
            // Toast Notification Banner (showToast)
            if let toast = store.toast {
                GavinToastBanner(store: store, text: toast.text)
                    .padding(.bottom, store.tab == .home ? 152 : 76)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(30)
            }
            
            // Active Bottom Sheet (showSheet)
            if let activeSheet = store.sheet {
                GavinSheetOverlay(store: store, activeSheet: activeSheet)
            }
            
            // Call Confirmation Alert Dialog (showConfirm)
            if let confirmIdx = store.confirm {
                GavinCallConfirmDialog(store: store, confirmIndex: confirmIdx)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        // Original LociStoa Dashboard Feature Sheets
        .sheet(item: $store.activeDashboardSheet) { sheet in
            switch sheet {
            case .map:
                MapView(theme: store.theme)
            case .links:
                CommonLinksView(store: store)
            case .schedule:
                ScheduleView(store: store)
            case .contacts:
                DirectoryContactsView(store: store)
            case .planner:
                HomeworkPlannerView(toDoList: store.toDoList, store: store)
            case .careerFair:
                CareerFairView(store: store)
            case .chatbot:
                AskLociStoaChatbotView(store: store)
            case .nomenclature:
                CampusNomenclatureView(store: store)
            }
        }
        // Contact Office Deep-Link to Interactive Indoor Map
        .sheet(item: $store.focusedMapContact) { contact in
            MapView(
                focusedContact: contact,
                theme: store.theme,
                onClose: {
                    store.focusedMapContact = nil
                }
            )
        }
    }
}

#Preview("LociStoa — Login & Gavin Dashboard") {
    ContentView()
}
