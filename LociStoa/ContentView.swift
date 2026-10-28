import SwiftUI

let lociBackground = Color(red: 0.85, green: 0.85, blue: 1.0)
let lociAccent = Color(red: 0.45, green: 0.31, blue: 0.76)

struct ContentView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                DashboardView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: isLoggedIn)
    }
}

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var showAdminSettings = false // New state for IT portal
    
    var body: some View {
        ZStack {
            lociBackground.ignoresSafeArea()
            
            // Top Right Dashboard Bypass
            VStack {
                HStack {
                    Spacer()
                    Button("Bypass") { isLoggedIn = true }
                        .font(.caption.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(lociAccent.opacity(0.2))
                        .foregroundColor(lociAccent)
                        .clipShape(Capsule())
                }
                .padding()
                Spacer()
            }
            
            // Bottom Right Admin/IT Bypass
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showAdminSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .padding(14)
                            .background(Color.white.opacity(0.6))
                            .foregroundColor(lociAccent)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                }
                .padding()
            }
            
            // Main Login Content
            VStack(spacing: 30) {
                VStack(spacing: 5) {
                    Text("LociStoa")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(lociAccent)
                    Text("Campus Management")
                        .font(.subheadline)
                        .foregroundColor(lociAccent.opacity(0.8))
                }
                .padding(.bottom, 20)
                
                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                }
                .padding(.horizontal, 30)
                
                VStack(spacing: 16) {
                    Button("Sign In") { isLoggedIn = true }
                        .buttonStyle(ModernButtonStyle())
                    
                    Text("OR")
                        .font(.caption.bold())
                        .foregroundColor(lociAccent.opacity(0.6))
                    
                    Button("Sign in with Google") { isLoggedIn = true }
                        .buttonStyle(ModernButtonStyle())
                    
                    Button("University SSO Sign-in") { isLoggedIn = true }
                        .buttonStyle(ModernButtonStyle())
                }
                .padding(.horizontal, 30)
            }
        }
        .sheet(isPresented: $showAdminSettings) {
            AdminSettingsView()
        }
    }
}

struct DashboardView: View {
    @State private var showingMapView = false
    @State private var showingCommonLinksView = false
    @State private var showingScheduleView = false
    @State private var showingDirectoryView = false
    @State private var showingHomeworkPlannerView = false
    @State private var showingCareerFairView = false // New state
    
    var body: some View {
        NavigationView {
            ZStack {
                lociBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            Button("Live Interactive Map") { showingMapView = true }
                                .buttonStyle(ModernButtonStyle())
                                .sheet(isPresented: $showingMapView) { MapView() }
                            
                            Button("Common Links") { showingCommonLinksView = true }
                                .buttonStyle(ModernButtonStyle())
                                .sheet(isPresented: $showingCommonLinksView) { CommonLinksView() }
                            
                            Button("Course Schedule") { showingScheduleView = true }
                                .buttonStyle(ModernButtonStyle())
                                .sheet(isPresented: $showingScheduleView) { ScheduleView() }
                            
                            Button("Directory Contacts") { showingDirectoryView = true }
                                .buttonStyle(ModernButtonStyle())
                            
                            Button("Task Flow Planner") { showingHomeworkPlannerView = true }
                                .buttonStyle(ModernButtonStyle())
                                .sheet(isPresented: $showingHomeworkPlannerView) { HomeworkPlannerView() }
                                
                            // New Career Fair Button
                            Button("Career Fair") { showingCareerFairView = true }
                                .buttonStyle(ModernButtonStyle())
                                .sheet(isPresented: $showingCareerFairView) { CareerFairView() }
                            
                            Button("Chatbot") { }
                                .buttonStyle(ModernButtonStyle())
                            
                            Button("Nomenclature") { }
                                .buttonStyle(ModernButtonStyle())
                        }
                        .padding(24)
                    }
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}
