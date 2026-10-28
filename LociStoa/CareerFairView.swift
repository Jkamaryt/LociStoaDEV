import SwiftUI

struct CareerFairView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    // Placeholder data
    let companies = ["Ford Motor Company", "Stryker", "Dow Chemical", "Caterpillar", "General Motors", "Oshkosh Corp"]
    
    var body: some View {
        NavigationView {
            ZStack {
                lociBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextField("Search attending companies...", text: $searchText)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(companies.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { company in
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(company)
                                            .font(.headline)
                                        Text("Booth: \(Int.random(in: 100...300))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(lociAccent.opacity(0.6))
                                }
                                .padding(20)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Fall Career Fair")
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
