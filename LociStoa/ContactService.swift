import Foundation
import Combine

@MainActor
final class DirectoryViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    // Update with your Mac's Wi-Fi IP (run `ipconfig getifaddr en0` in Terminal) when running on a physical iPhone
    private let deviceServerIP = "192.168.1.100"
    private let serverPort = "8080"

    private var serverURL: URL? {
        #if targetEnvironment(simulator)
        return URL(string: "http://localhost:\(serverPort)/api/contacts")
        #else
        return URL(string: "http://\(deviceServerIP):\(serverPort)/api/contacts")
        #endif
    }

    var filteredContacts: [Contact] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return contacts
        }
        return contacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(searchText) ||
            contact.department.localizedCaseInsensitiveContains(searchText) ||
            contact.role.localizedCaseInsensitiveContains(searchText) ||
            (contact.office ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    func fetchContacts() async {
        guard let url = serverURL else {
            self.errorMessage = "Invalid server URL configuration."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 6.0
            let session = URLSession(configuration: config)

            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            self.contacts = try JSONDecoder().decode([Contact].self, from: data)
        } catch {
            self.errorMessage = "Could not connect to terminal server. Make sure `python3 server.py` is running on your Mac."
        }

        isLoading = false
    }
}
