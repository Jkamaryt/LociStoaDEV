import SwiftUI

struct ScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var fridaySched = false
    
    // Example data array to keep the view clean
    let regularTimes = ["08:30 - 09:18", "09:22 - 10:08", "10:13 - 11:07", "11:12 - 11:58", "12:03 - 12:49", "12:54 - 01:40", "01:45 - 02:31", "02:36 - 03:22"]
    let fridayTimes = ["08:30 - 09:17", "09:22 - 10:08", "10:13 - 11:07", "11:12 - 11:58", "12:03 - 12:49", "12:54 - 01:40", "01:45 - 02:31", "02:36 - 03:22"]
    
    var body: some View {
        NavigationView {
            ZStack {
                lociBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Toggle("Friday Schedule", isOn: $fridaySched)
                            .font(.headline)
                            .padding()
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(12)
                            .tint(lociAccent)
                            .padding(.bottom, 10)
                        
                        ForEach(0..<8, id: \.self) { index in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.headline.bold())
                                    .frame(width: 40, height: 40)
                                    .background(lociAccent.opacity(0.2))
                                    .foregroundColor(lociAccent)
                                    .clipShape(Circle())
                                
                                Spacer()
                                
                                Text(fridaySched ? fridayTimes[index] : regularTimes[index])
                                    .font(.system(.title3, design: .monospaced))
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle(fridaySched ? "Friday Schedule" : "Regular Schedule")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

