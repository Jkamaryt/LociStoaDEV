import SwiftUI

struct ScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    var store: LociStoaStore? = nil
    @State private var fridaySched = false
    
    // Original period times preserved 100%
    let regularTimes = LociStoaStore.regularPeriodTimes
    let fridayTimes = LociStoaStore.fridayPeriodTimes
    
    private var theme: LociTheme {
        store?.theme ?? .purple
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                (store?.effectiveBgColor ?? theme.bg).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("COURSE PERIODS")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            Text(fridaySched ? "Friday Schedule" : "Regular Schedule")
                                .font(LociFont.display(32, weight: .heavy))
                                .foregroundColor(theme.ink)
                        }
                        
                        // Gavin-styled Friday Schedule Toggle Card
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Friday Schedule")
                                    .font(LociFont.sans(16, weight: .bold))
                                    .foregroundColor(theme.ink)
                                Text(fridaySched ? "Showing Friday period times" : "Showing Mon–Thu regular period times")
                                    .font(LociFont.sans(13))
                                    .foregroundColor(theme.sub)
                            }
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.18)) {
                                    fridaySched.toggle()
                                    store?.fridayScheduleEnabled = fridaySched
                                }
                            }) {
                                ZStack(alignment: fridaySched ? .trailing : .leading) {
                                    Capsule()
                                        .fill(fridaySched ? theme.accent : theme.check)
                                        .frame(width: 52, height: 32)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 26, height: 26)
                                        .shadow(color: .black.opacity(0.3), radius: 1.5, x: 0, y: 1)
                                        .padding(.horizontal, 3)
                                }
                                .frame(width: 56, height: 44)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(theme.line, lineWidth: 1)
                        )
                        
                        // 8 Period Rows inside Gavin Card
                        VStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { index in
                                VStack(spacing: 0) {
                                    if index > 0 {
                                        Rectangle().fill(theme.rule).frame(height: 1)
                                    }
                                    HStack(spacing: 14) {
                                        Text("\(index + 1)")
                                            .font(LociFont.display(16, weight: .heavy))
                                            .frame(width: 42, height: 42)
                                            .background(theme.tint)
                                            .foregroundColor(theme.ink)
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Period \(index + 1)")
                                                .font(LociFont.sans(15, weight: .bold))
                                                .foregroundColor(theme.ink)
                                            Text(fridaySched ? "Friday Bell" : "Regular Bell")
                                                .font(LociFont.sans(12.5))
                                                .foregroundColor(theme.sub)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(fridaySched ? fridayTimes[index] : regularTimes[index])
                                            .font(LociFont.sans(15, weight: .bold).monospacedDigit())
                                            .foregroundColor(theme.ink)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(theme.tint)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                    .padding(.vertical, 8)
                                    .frame(minHeight: 64)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(theme.line, lineWidth: 1)
                        )
                    }
                    .padding(20)
                }
            }
            .navigationTitle(fridaySched ? "Friday Schedule" : "Regular Schedule")
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
                    fridaySched = store.fridayScheduleEnabled
                }
            }
        }
    }
}
