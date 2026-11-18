import SwiftUI

struct CareerFairCompany: Identifiable {
    var id: String { name }
    let name: String
    let booth: String
    let majors: String
    let location: String
}

struct CareerFairView: View {
    @Environment(\.dismiss) private var dismiss
    var store: LociStoaStore? = nil
    @State private var searchText = ""
    @State private var selectedCompany: CareerFairCompany? = nil
    
    // Original companies preserved + rich booth details
    let companies: [CareerFairCompany] = [
        CareerFairCompany(name: "Ford Motor Company", booth: "Booth 114", majors: "ME, ECE, CS, MIS, Business", location: "SDC Multipurpose Room • Row A"),
        CareerFairCompany(name: "Stryker", booth: "Booth 128", majors: "BME, ME, EE, CS, Supply Chain", location: "SDC Multipurpose Room • Row B"),
        CareerFairCompany(name: "Dow Chemical", booth: "Booth 142", majors: "ChemE, Chemistry, MSE, ME, EnvE", location: "SDC Multipurpose Room • Row B"),
        CareerFairCompany(name: "Caterpillar", booth: "Booth 165", majors: "ME, ECE, CS, MET, Accounting", location: "SDC Multipurpose Room • Row C"),
        CareerFairCompany(name: "General Motors", booth: "Booth 204", majors: "ECE, ME, CS, Software, Finance", location: "SDC Multipurpose Room • Row D"),
        CareerFairCompany(name: "Oshkosh Corp", booth: "Booth 219", majors: "ME, EE, CS, Industrial, Business", location: "SDC Multipurpose Room • Row D"),
        CareerFairCompany(name: "NextEra Energy", booth: "Booth 235", majors: "EE, Civil, EnvE, Business", location: "SDC Multipurpose Room • Row E"),
        CareerFairCompany(name: "3M", booth: "Booth 248", majors: "ChemE, MSE, ME, Data Science", location: "SDC Multipurpose Room • Row E")
    ]
    
    private var theme: LociTheme {
        store?.theme ?? .purple
    }
    
    private var filteredCompanies: [CareerFairCompany] {
        companies.filter { company in
            guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return true }
            return company.name.localizedCaseInsensitiveContains(searchText)
                || company.booth.localizedCaseInsensitiveContains(searchText)
                || company.majors.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                (store?.effectiveBgColor ?? theme.bg).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SDC MULTIPURPOSE ROOM")
                                .font(LociFont.sans(12, weight: .bold))
                                .tracking(0.96)
                                .foregroundColor(theme.sub)
                            Text("Fall Career Fair")
                                .font(LociFont.display(32, weight: .heavy))
                                .foregroundColor(theme.ink)
                        }
                        
                        // Search Input (Gavin Style)
                        HStack(spacing: 10) {
                            LociIcon(kind: .search, size: 20, lineWidth: 2, color: theme.ink)
                            TextField("Search attending companies...", text: $searchText)
                                .font(LociFont.sans(16))
                                .foregroundColor(theme.ink)
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    LociIcon(kind: .close, size: 16, lineWidth: 2.2, color: theme.sub)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(theme.strong, lineWidth: 1.5)
                        )
                        
                        Text("\(filteredCompanies.count) \(filteredCompanies.count == 1 ? "employer" : "employers") attending")
                            .font(LociFont.sans(13, weight: .semibold))
                            .foregroundColor(theme.sub)
                        
                        // Attending Companies Card List
                        if !filteredCompanies.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(Array(filteredCompanies.enumerated()), id: \.element.id) { idx, company in
                                    let isExpanded = (selectedCompany?.id == company.id)
                                    VStack(spacing: 0) {
                                        if idx > 0 {
                                            Rectangle().fill(theme.rule).frame(height: 1)
                                        }
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.18)) {
                                                selectedCompany = isExpanded ? nil : company
                                            }
                                        }) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack(spacing: 12) {
                                                    VStack(alignment: .leading, spacing: 3) {
                                                        Text(company.name)
                                                            .font(LociFont.sans(16, weight: .bold))
                                                            .foregroundColor(theme.ink)
                                                        Text("Hiring: \(company.majors)")
                                                            .font(LociFont.sans(13))
                                                            .foregroundColor(theme.sub)
                                                    }
                                                    Spacer()
                                                    Text(company.booth)
                                                        .font(LociFont.sans(12.5, weight: .bold))
                                                        .foregroundColor(theme.ink)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 5)
                                                        .background(theme.tint)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                                    
                                                    LociIcon(kind: .chevronRight, size: 18, lineWidth: 2.2, color: theme.sub)
                                                }
                                                
                                                if isExpanded {
                                                    HStack(spacing: 8) {
                                                        LociIcon(kind: .mapPin, size: 15, lineWidth: 2, color: theme.accent)
                                                        Text(company.location)
                                                            .font(LociFont.sans(13, weight: .semibold))
                                                            .foregroundColor(theme.ink)
                                                        Spacer()
                                                    }
                                                    .padding(10)
                                                    .background(theme.tint)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                                }
                                            }
                                            .padding(.vertical, 12)
                                            .frame(minHeight: 68)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
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
                        } else {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("No companies match that search")
                                    .font(LociFont.display(19, weight: .bold))
                                    .foregroundColor(theme.ink)
                                Text("Try searching by company name, booth number, or major.")
                                    .font(LociFont.sans(14))
                                    .foregroundColor(theme.sub)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(theme.line, lineWidth: 1)
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Fall Career Fair")
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
