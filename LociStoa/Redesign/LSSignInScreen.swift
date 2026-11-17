import SwiftUI

// LociStoa redesign: the sign-in screen.
//
// This is a stand-in for real Google or Microsoft sign-in. It only looks at the email's
// domain (the part after the @) and matches it against schools.csv to pick the school,
// which in turn picks the colors. It never asks for a password. Real sign-in needs a backend.

struct LSSignInScreen: View {
    @EnvironmentObject var store: LSStore
    @State private var email = ""
    @State private var error = ""

    // This screen is always LociStoa purple, because no school is known yet.
    private let p = LSPalette.purple

    private func submit(_ typed: String) {
        error = store.signIn(typed) ?? ""
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("LociStoa").font(.ls(40, .heavy))
                    Text("Your campus, in one place.")
                        .font(.ls(16, .semibold))
                        .foregroundStyle(p.sub)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Sign in with your school account").font(.ls(21, .bold))
                    Text("Your school email decides which campus and colors you see.")
                        .font(.ls(14))
                        .foregroundStyle(p.sub)

                    Text("SCHOOL EMAIL")
                        .font(.ls(12, .bold))
                        .tracking(1)
                        .foregroundStyle(p.sub)
                        .padding(.top, 4)
                    TextField("you@mtu.edu", text: $email)
                        .font(.ls(16))
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        #endif
                        .autocorrectionDisabled(true)
                        .submitLabel(.go)
                        .onSubmit {
                            submit(email)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(p.strong, lineWidth: 1.5)
                        )
                        .accessibilityLabel("School email")

                    if !error.isEmpty {
                        Text(error)
                            .font(.ls(14, .semibold))
                            .foregroundStyle(Color(lsHex: 0x8C1D18))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(lsHex: 0xFDECEA))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    Button {
                        submit(email)
                    } label: {
                        Text("Continue")
                            .font(.ls(16, .bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(p.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(LSPressStyle())
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(p.line, lineWidth: 1))

                // One tap per school in schools.csv, so a demo does not need typing.
                VStack(alignment: .leading, spacing: 10) {
                    Text("DEMO ACCOUNTS")
                        .font(.ls(12, .bold))
                        .tracking(1)
                        .foregroundStyle(p.sub)
                    ForEach(store.data.schools) { school in
                        Button {
                            submit("you@" + school.domain)
                        } label: {
                            Text("you@" + school.domain)
                                .font(.ls(14, .semibold))
                                .padding(.horizontal, 16)
                                .frame(height: 44)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(p.strong, lineWidth: 1.5))
                        }
                        .buttonStyle(LSPressStyle())
                    }
                }

                Text("Prototype: this screen stands in for Google or Microsoft sign-in. It never asks for a password and nothing you type leaves this phone.")
                    .font(.ls(12.5))
                    .foregroundStyle(p.sub)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 56)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
        .foregroundStyle(p.ink)
        .tint(p.accent)
        .background(p.bg.ignoresSafeArea())
    }
}
