import SwiftUI

struct CommonLinksView: View {
    @Environment(\.dismiss) private var dismiss
    var store: LociStoaStore? = nil
    
    private var theme: LociTheme {
        store?.theme ?? .purple
    }
    
    private let links: [(title: String, subtitle: String, url: String)] = [
        ("MyMichiganTech", "Student portal, HuskyCard, and campus services", "https://mymichigantech.mtu.edu/"),
        ("Canvas", "Course modules, assignments, and grades", "https://mtu.instructure.com/"),
        ("Banweb", "Registration, transcripts, and financial aid", "https://www.banweb.mtu.edu/"),
        ("Academic Calendar", "Semester dates, breaks, and exam schedules", "https://www.mtu.edu/registrar/students/calendars/")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                (store?.effectiveBgColor ?? theme.bg).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("OPEN IN YOUR BROWSER")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            Text("Common Links")
                                .font(LociFont.display(32, weight: .heavy))
                                .foregroundColor(theme.ink)
                        }
                        
                        // 2-Column Gavin Quick Links Grid
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                            ForEach(links, id: \.title) { link in
                                if let url = URL(string: link.url) {
                                    Link(destination: url) {
                                        HStack(spacing: 8) {
                                            Text(link.title)
                                                .font(LociFont.sans(14.5, weight: .bold))
                                                .foregroundColor(theme.ink)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                            Spacer(minLength: 2)
                                            LociIcon(kind: .externalArrow, size: 16, lineWidth: 2.2, color: theme.ink)
                                        }
                                        .padding(.horizontal, 14)
                                        .frame(height: 56)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .stroke(theme.line, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Detailed List Card
                        VStack(spacing: 0) {
                            ForEach(Array(links.enumerated()), id: \.element.title) { idx, link in
                                VStack(spacing: 0) {
                                    if idx > 0 {
                                        Rectangle().fill(theme.rule).frame(height: 1)
                                    }
                                    if let url = URL(string: link.url) {
                                        Link(destination: url) {
                                            HStack(spacing: 12) {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(link.title)
                                                        .font(LociFont.sans(15.5, weight: .bold))
                                                        .foregroundColor(theme.ink)
                                                    Text(link.subtitle)
                                                        .font(LociFont.sans(13))
                                                        .foregroundColor(theme.sub)
                                                }
                                                Spacer()
                                                LociIcon(kind: .externalArrow, size: 18, lineWidth: 2.2, color: theme.ink)
                                            }
                                            .padding(.vertical, 10)
                                            .frame(minHeight: 62)
                                            .contentShape(Rectangle())
                                        }
                                    }
                                }
                            }
                        }
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
            .navigationTitle("Common Links")
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
        }
    }
}
