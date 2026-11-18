import SwiftUI

struct DirectoryContactsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DirectoryViewModel()
    var store: LociStoaStore? = nil
    var onClose: (() -> Void)? = nil

    @State private var selectedContactForMap: Contact?
    @FocusState private var isSearchFocused: Bool
    
    private var theme: LociTheme {
        store?.theme ?? .purple
    }

    var body: some View {
        NavigationStack {
            ZStack {
                (store?.effectiveBgColor ?? theme.bg).ignoresSafeArea()

                if viewModel.isLoading && viewModel.contacts.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(theme.accent)
                        Text("Loading MTU directory from server...")
                            .font(LociFont.sans(14, weight: .semibold))
                            .foregroundColor(theme.sub)
                    }
                } else if let error = viewModel.errorMessage, viewModel.contacts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(theme.accent)
                        Text("Server Offline")
                            .font(LociFont.display(22, weight: .bold))
                            .foregroundColor(theme.ink)
                        Text(error)
                            .font(LociFont.sans(14))
                            .foregroundColor(theme.sub)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button("Retry Connection") {
                            Task { await viewModel.fetchContacts() }
                        }
                        .font(LociFont.sans(15, weight: .bold))
                        .padding(.horizontal, 20)
                        .frame(height: 48)
                        .background(theme.accent)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 14) {
                            // Search Bar (Gavin Style)
                            HStack(spacing: 10) {
                                LociIcon(kind: .search, size: 20, lineWidth: 2, color: theme.ink)
                                TextField("Search name, role, building, or department...", text: $viewModel.searchText)
                                    .font(LociFont.sans(16))
                                    .foregroundColor(theme.ink)
                                    .focused($isSearchFocused)
                                if !viewModel.searchText.isEmpty {
                                    Button(action: { viewModel.searchText = "" }) {
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

                            Text("\(viewModel.filteredContacts.count) \(viewModel.filteredContacts.count == 1 ? "contact" : "contacts") synced")
                                .font(LociFont.sans(13, weight: .semibold))
                                .foregroundColor(theme.sub)

                            // Contact Cards (Gavin Style)
                            ForEach(viewModel.filteredContacts) { contact in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(alignment: .top) {
                                        Text(contact.name)
                                            .font(LociFont.sans(16, weight: .bold))
                                            .foregroundColor(theme.ink)
                                        Spacer()
                                        Text(contact.role)
                                            .font(LociFont.sans(12, weight: .bold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(theme.tint)
                                            .foregroundColor(theme.ink)
                                            .clipShape(Capsule())
                                    }

                                    Text(contact.department)
                                        .font(LociFont.sans(13.5))
                                        .foregroundColor(theme.sub)

                                    if let office = contact.office {
                                        Button(action: {
                                            isSearchFocused = false
                                            selectedContactForMap = contact
                                        }) {
                                            HStack(spacing: 6) {
                                                LociIcon(kind: .mapPin, size: 16, lineWidth: 2, color: theme.accent)
                                                Text(office)
                                                    .font(LociFont.sans(13, weight: .bold))
                                                    .foregroundColor(theme.ink)
                                                Text("• Locate on Map")
                                                    .font(LociFont.sans(12, weight: .semibold))
                                                    .foregroundColor(theme.accent)
                                                Spacer()
                                                LociIcon(kind: .chevronRight, size: 15, lineWidth: 2.2, color: theme.sub)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 9)
                                            .background(theme.tint)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        }
                                        .buttonStyle(LociPressButtonStyle())
                                    }

                                    Rectangle().fill(theme.rule).frame(height: 1)

                                    HStack {
                                        if let phoneURL = URL(string: "tel://\(contact.phone)") {
                                            Link(destination: phoneURL) {
                                                HStack(spacing: 6) {
                                                    LociIcon(kind: .phone, size: 15, lineWidth: 2, color: theme.accent)
                                                    Text(contact.phone)
                                                        .font(LociFont.sans(13, weight: .bold))
                                                        .foregroundColor(theme.ink)
                                                }
                                            }
                                        }
                                        Spacer()
                                        if let emailURL = URL(string: "mailto:\(contact.email)") {
                                            Link(destination: emailURL) {
                                                HStack(spacing: 6) {
                                                    LociIcon(kind: .mail, size: 15, lineWidth: 2, color: theme.accent)
                                                    Text(contact.email)
                                                        .font(LociFont.sans(13, weight: .bold))
                                                        .foregroundColor(theme.ink)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(theme.line, lineWidth: 1)
                                )
                            }
                        }
                        .padding(20)
                    }
                    .refreshable {
                        await viewModel.fetchContacts()
                    }
                }
            }
            .navigationTitle("Directory Contacts")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isSearchFocused = false
                        if let onClose {
                            onClose()
                        } else {
                            dismiss()
                        }
                    }
                    .font(LociFont.sans(15, weight: .bold))
                    .foregroundColor(theme.ink)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await viewModel.fetchContacts() }
                    } label: {
                        LociIcon(kind: .refresh, size: 18, lineWidth: 2.2, color: theme.accent)
                    }
                }
            }
            .sheet(item: $selectedContactForMap) { contact in
                MapView(
                    focusedContact: contact,
                    onClose: {
                        selectedContactForMap = nil
                    }
                )
            }
            .task {
                if viewModel.contacts.isEmpty {
                    await viewModel.fetchContacts()
                }
            }
        }
    }
}
