import SwiftUI

struct CommonLinksView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                lociBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Link("MyMichiganTech", destination: URL(string: "https://mymichigantech.mtu.edu/")!)
                        .buttonStyle(ModernButtonStyle())
                        
                    Link("Canvas", destination: URL(string: "https://mtu.instructure.com/")!)
                        .buttonStyle(ModernButtonStyle())
                        
                    Link("Banweb", destination: URL(string: "https://www.banweb.mtu.edu/")!)
                        .buttonStyle(ModernButtonStyle())
                    
                    Link("Academic Calendar", destination: URL(string: "https://www.mtu.edu/registrar/students/calendars/")!)
                        .buttonStyle(ModernButtonStyle())
                    
                    Spacer()
                }
                .padding(24)
                .padding(.top, 20)
            }
            .navigationTitle("Common Links")
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
