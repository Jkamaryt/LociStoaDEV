import SwiftUI

struct AdminSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var store: LociStoaStore? = nil
    
    @State private var isAuthenticated = false
    @State private var adminPin = ""
    @State private var pinError = false
    
    // Prototype state for color pickers
    @State private var primaryColor = lociBackground
    @State private var secondaryColor = lociAccent
    @State private var selectedTheme: LociTheme = .purple
    @State private var useCustomPickerColors: Bool = false
    
    private var theme: LociTheme {
        store?.theme ?? selectedTheme
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                (useCustomPickerColors ? primaryColor : (store?.effectiveBgColor ?? theme.bg))
                    .ignoresSafeArea()
                
                if isAuthenticated {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("IT ADMINISTRATOR")
                                    .font(LociFont.sans(12, weight: .bold))
                                    .tracking(0.96)
                                    .foregroundColor(theme.sub)
                                Text("Tenant Settings")
                                    .font(LociFont.display(32, weight: .heavy))
                                    .foregroundColor(theme.ink)
                            }
                            
                            // 1. Gavin Theme Presets
                            VStack(alignment: .leading, spacing: 10) {
                                Text("CAMPUS THEME PRESETS")
                                    .font(LociFont.sans(12, weight: .bold))
                                    .tracking(0.96)
                                    .foregroundColor(theme.sub)
                                
                                HStack(spacing: 8) {
                                    ForEach(LociTheme.allCases) { t in
                                        let isSelected = (selectedTheme == t && !useCustomPickerColors)
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedTheme = t
                                                useCustomPickerColors = false
                                                primaryColor = t.bg
                                                secondaryColor = t.accent
                                                store?.theme = t
                                                store?.customPrimaryBgColor = nil
                                                store?.customSecondaryAccentColor = nil
                                            }
                                        }) {
                                            VStack(spacing: 7) {
                                                Circle()
                                                    .fill(t.swatch)
                                                    .frame(width: 28, height: 28)
                                                Text(t.label)
                                                    .font(LociFont.sans(13, weight: isSelected ? .bold : .semibold))
                                                    .foregroundColor(theme.ink)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 80)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                    .stroke(isSelected ? t.accent : theme.line, lineWidth: 2)
                                            )
                                        }
                                        .buttonStyle(LociPressButtonStyle())
                                    }
                                }
                            }
                            
                            // 2. University Branding Colors (Original ColorPickers)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("UNIVERSITY BRANDING COLORS")
                                    .font(LociFont.sans(12, weight: .bold))
                                    .tracking(0.96)
                                    .foregroundColor(theme.sub)
                                
                                VStack(spacing: 0) {
                                    ColorPicker("Primary Background", selection: Binding(
                                        get: { primaryColor },
                                        set: { newVal in
                                            primaryColor = newVal
                                            useCustomPickerColors = true
                                        }
                                    ))
                                    .font(LociFont.sans(15, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                    .frame(minHeight: 56)
                                    
                                    Rectangle().fill(theme.rule).frame(height: 1)
                                    
                                    ColorPicker("Secondary Accent", selection: Binding(
                                        get: { secondaryColor },
                                        set: { newVal in
                                            secondaryColor = newVal
                                            useCustomPickerColors = true
                                        }
                                    ))
                                    .font(LociFont.sans(15, weight: .semibold))
                                    .foregroundColor(theme.ink)
                                    .frame(minHeight: 56)
                                }
                                .padding(.horizontal, 16)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(theme.line, lineWidth: 1)
                                )
                                
                                Text("Changes will propagate globally across all student instances upon deployment.")
                                    .font(LociFont.sans(13))
                                    .foregroundColor(theme.sub)
                            }
                            
                            // 3. Save & Deploy to Tenant Button
                            Button(action: {
                                store?.theme = selectedTheme
                                if useCustomPickerColors {
                                    store?.customPrimaryBgColor = primaryColor
                                    store?.customSecondaryAccentColor = secondaryColor
                                } else {
                                    store?.customPrimaryBgColor = nil
                                    store?.customSecondaryAccentColor = nil
                                }
                                dismiss()
                            }) {
                                Text("Save & Deploy to Tenant")
                                    .font(LociFont.sans(16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(useCustomPickerColors ? secondaryColor : theme.accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(LociPressButtonStyle())
                            
                            if useCustomPickerColors || store?.customPrimaryBgColor != nil {
                                Button(action: {
                                    useCustomPickerColors = false
                                    primaryColor = selectedTheme.bg
                                    secondaryColor = selectedTheme.accent
                                    store?.customPrimaryBgColor = nil
                                    store?.customSecondaryAccentColor = nil
                                }) {
                                    Text("Reset Custom Colors to Theme Default")
                                        .font(LociFont.sans(14, weight: .bold))
                                        .foregroundColor(theme.ink)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(theme.tint)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(LociPressButtonStyle())
                            }
                        }
                        .padding(20)
                    }
                } else {
                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(theme.tint)
                                .frame(width: 84, height: 84)
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(theme.accent)
                        }
                        .padding(.bottom, 4)
                        
                        Text("IT Administrator Access")
                            .font(LociFont.display(26, weight: .heavy))
                            .foregroundColor(theme.ink)
                        
                        Text("Enter your tenant administrator PIN to customize university branding and theme colors.")
                            .font(LociFont.sans(14))
                            .foregroundColor(theme.sub)
                            .multilineTextAlignment(.center)
                        
                        SecureField("Enter Admin PIN (1234)", text: $adminPin)
                            .font(LociFont.sans(16))
                            .foregroundColor(theme.ink)
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(pinError ? Color(hex: 0xB3261E) : theme.strong, lineWidth: 1.5)
                            )
                            .onSubmit {
                                authenticatePin()
                            }
                        
                        if pinError {
                            Text("Invalid PIN. Hint: Use 1234 for the prototype.")
                                .font(LociFont.sans(13, weight: .semibold))
                                .foregroundColor(Color(hex: 0xB3261E))
                        }
                        
                        Button(action: {
                            authenticatePin()
                        }) {
                            Text("Authenticate")
                                .font(LociFont.sans(16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(theme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(LociPressButtonStyle())
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(theme.line, lineWidth: 1)
                    )
                    .padding(24)
                }
            }
            .navigationTitle(isAuthenticated ? "Tenant Settings" : "Restricted")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(LociFont.sans(15, weight: .bold))
                        .foregroundColor(theme.ink)
                }
            }
            .onAppear {
                if let store {
                    selectedTheme = store.theme
                    primaryColor = store.customPrimaryBgColor ?? store.theme.bg
                    secondaryColor = store.customSecondaryAccentColor ?? store.theme.accent
                    useCustomPickerColors = (store.customPrimaryBgColor != nil || store.customSecondaryAccentColor != nil)
                }
            }
        }
    }
    
    private func authenticatePin() {
        if adminPin == "1234" {
            pinError = false
            withAnimation(.easeInOut(duration: 0.22)) {
                isAuthenticated = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.16)) {
                pinError = true
            }
        }
    }
}
