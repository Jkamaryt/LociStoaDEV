import SwiftUI

struct DirectoryView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                lociBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Coming Soon")
                    Spacer()
                }
                .padding(24)
                .padding(.top, 20)
            }
            .navigationTitle("Directory")
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