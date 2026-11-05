import SwiftUI

struct DirectoryContactsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = DirectoryViewModel()
    
    @State private var selectedContactForMap: Contact?

    var body: some View {
        NavigationView {
            ZStack {
                lociBackground.ignoresSafeArea()

                if viewModel.isLoading && viewModel.contacts.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(lociAccent)
                        Text("Loading MTU directory from server...")
                            .font(.subheadline)
                            .foregroundColor(lociAccent.opacity(0.8))
                    }
                } else if let error = viewModel.errorMessage, viewModel.contacts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 48))
                            .foregroundColor(lociAccent)
                        Text("Server Offline")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button("Retry Connection") {
                            Task { await viewModel.fetchContacts() }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(lociAccent)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(lociAccent)
                                TextField("Search name, role, building, or department...", text: $viewModel.searchText)
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)

                            // Contact Cards
                            ForEach(viewModel.filteredContacts) { contact in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(contact.name)
                                            .font(.headline.bold())
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(contact.role)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(lociAccent.opacity(0.15))
                                            .foregroundColor(lociAccent)
                                            .clipShape(Capsule())
                                    }

                                    Text(contact.department)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    if let office = contact.office {
                                        Button(action: {
                                            selectedContactForMap = contact
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "mappin.and.ellipse")
                                                    .foregroundColor(lociAccent)
                                                Text(office)
                                                    .font(.caption.bold())
                                                    .foregroundColor(lociAccent)
                                                Text("• Locate on Map")
                                                    .font(.caption2.bold())
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.caption2)
                                                    .foregroundColor(lociAccent)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                            .background(lociBackground.opacity(0.45))
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        }
                                    }

                                    Divider()

                                    HStack {
                                        if let phoneURL = URL(string: "tel://\(contact.phone)") {
                                            Link(destination: phoneURL) {
                                                Label(contact.phone, systemImage: "phone.fill")
                                                    .font(.caption.bold())
                                                    .foregroundColor(lociAccent)
                                            }
                                        }
                                        Spacer()
                                        if let emailURL = URL(string: "mailto:\(contact.email)") {
                                            Link(destination: emailURL) {
                                                Label(contact.email, systemImage: "envelope.fill")
                                                    .font(.caption.bold())
                                                    .foregroundColor(lociAccent)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding(24)
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
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(lociAccent)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await viewModel.fetchContacts() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(lociAccent)
                    }
                }
            }
            .sheet(item: $selectedContactForMap) { contact in
                MapView(focusedContact: contact)
            }
            .task {
                if viewModel.contacts.isEmpty {
                    await viewModel.fetchContacts()
                }
            }
        }
    }
}
