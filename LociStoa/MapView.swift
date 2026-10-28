import SwiftUI

struct MapView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                lociBackground.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("Select a Floor")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(lociAccent)
                        .padding(.top, 40)
                    
                    HStack(spacing: 20) {
                        NavigationLink(destination: MapImageView(floorNum: "1F")) { Text("1F") }
                            .buttonStyle(ModernCompactButtonStyle())
                        
                        NavigationLink(destination: MapImageView(floorNum: "2F")) { Text("2F") }
                            .buttonStyle(ModernCompactButtonStyle())
                           
                        NavigationLink(destination: MapImageView(floorNum: "3F")) { Text("3F") }
                            .buttonStyle(ModernCompactButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Interactive Map")
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
