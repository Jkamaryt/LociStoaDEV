import SwiftUI
#if canImport(CoreGraphics)
import CoreGraphics
#endif
#if canImport(ImageIO)
import ImageIO
#endif

// LociStoa redesign: colors and the small reusable pieces every screen shares.

// MARK: - Colors

extension Color {
    /// Color(lsHex: 0x734FC2) is the same as the web color #734FC2.
    init(lsHex hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}

/// One set of colors. The school decides which set a student gets (see schools.csv),
/// and each school has a light and a dark version.
struct LSPalette {
    let id: String
    var bg: Color           // screen background
    var card: Color         // cards, panels, text boxes
    var ink: Color          // main text
    var sub: Color          // secondary text
    var tint: Color         // soft fills
    var line: Color         // card borders
    var rule: Color         // lines between rows
    var strong: Color       // outlines of text boxes and chips
    var check: Color        // empty checkboxes, switches that are off
    var accent: Color       // main buttons
    var onAccent: Color     // text on main buttons
    var accentInk: Color    // the accent when it is drawn on a card: ticked boxes, switches, links
    var onAccentInk: Color  // the check mark inside a ticked box
    var word: Color         // text links
    var solid: Color        // selected chips and days
    var onSolid: Color      // text on those
    var deep: Color         // dark badges: avatars, the "Marked done" message
    var onDeep: Color       // text on those
    var heroBg: Color       // the Next class card
    var heroFg: Color       // its main text
    var h1: Color           // its small label
    var h2: Color           // its second line
    var navBg: Color        // tab bar
    var navOn: Color        // selected tab
    var navSub: Color       // other tabs
    var navLine: Color      // line above the tab bar
    var segOn: Color        // the selected half of a Directory / Departments style switch

    static let danger = Color(lsHex: 0xB3261E)

    /// Starts a palette from its basic colors. Everything else gets a sensible default
    /// that a theme can then change.
    init(id: String, bg: UInt32, card: UInt32 = 0xFFFFFF, ink: UInt32, sub: UInt32, tint: UInt32, line: UInt32,
         rule: UInt32, strong: UInt32, check: UInt32, accent: UInt32, word: UInt32, h1: UInt32, h2: UInt32) {
        self.id = id
        self.bg = Color(lsHex: bg)
        self.card = Color(lsHex: card)
        self.ink = Color(lsHex: ink)
        self.sub = Color(lsHex: sub)
        self.tint = Color(lsHex: tint)
        self.line = Color(lsHex: line)
        self.rule = Color(lsHex: rule)
        self.strong = Color(lsHex: strong)
        self.check = Color(lsHex: check)
        self.accent = Color(lsHex: accent)
        self.onAccent = Color.white
        self.accentInk = Color(lsHex: accent)
        self.onAccentInk = Color.white
        self.word = Color(lsHex: word)
        self.solid = Color(lsHex: ink)
        self.onSolid = Color.white
        self.deep = Color(lsHex: ink)
        self.onDeep = Color.white
        self.heroBg = Color(lsHex: ink)
        self.heroFg = Color.white
        self.h1 = Color(lsHex: h1)
        self.h2 = Color(lsHex: h2)
        self.navBg = Color(lsHex: card)
        self.navOn = Color(lsHex: accent)
        self.navSub = Color(lsHex: sub)
        self.navLine = Color(lsHex: line)
        self.segOn = Color(lsHex: card)
    }

    // LociStoa's own purple. Only the sign-in screen uses it, before a school is known.
    static let purple = LSPalette(id: "purple", bg: 0xD9D9FF, ink: 0x2B1F52, sub: 0x5E5873, tint: 0xECE7FB,
                                  line: 0xCFCBEE, rule: 0xEEEBFA, strong: 0x968DBA, check: 0x7A6FA6,
                                  accent: 0x734FC2, word: 0x4A2F96, h1: 0xD6CFF2, h2: 0xEDE9FB)

    // Michigan Tech: black and gold (PMS 116, #FFCD00) from the university brand page.
    // Gold is used solid with dark text on it, or on a dark bar. Never as text on white.
    static let mtuLight: LSPalette = {
        var p = LSPalette(id: "mtu", bg: 0xEFEFEF, ink: 0x1F1F1F, sub: 0x565656, tint: 0xEBEBEB,
                          line: 0xDCDCDC, rule: 0xEDEDED, strong: 0x8C8C8C, check: 0x767676,
                          accent: 0xFFCD00, word: 0x1F1F1F, h1: 0x3D3100, h2: 0x2E2E2E)
        p.onAccent = Color(lsHex: 0x1A1A1A)
        p.accentInk = Color(lsHex: 0x1F1F1F)
        p.solid = Color(lsHex: 0xFFCD00)
        p.onSolid = Color(lsHex: 0x1A1A1A)
        p.deep = Color(lsHex: 0x2B2B2B)
        p.heroBg = Color(lsHex: 0xFFCD00)
        p.heroFg = Color(lsHex: 0x1A1A1A)
        p.navBg = Color(lsHex: 0x1E1E1E)
        p.navOn = Color(lsHex: 0xFFCD00)
        p.navSub = Color(lsHex: 0xC4C4C4)
        p.navLine = Color(lsHex: 0x1E1E1E)
        return p
    }()

    static let mtuDark: LSPalette = {
        var p = LSPalette(id: "mtu", bg: 0x0B0B0B, card: 0x1B1B1B, ink: 0xF3F3F3, sub: 0xABABAB, tint: 0x2B2B2B,
                          line: 0x303030, rule: 0x282828, strong: 0x727272, check: 0x8C8C8C,
                          accent: 0xFFCD00, word: 0xFFCD00, h1: 0x3D3100, h2: 0x2A2A2A)
        p.onAccent = Color(lsHex: 0x111111)
        p.onAccentInk = Color(lsHex: 0x111111)
        p.solid = Color(lsHex: 0xFFCD00)
        p.onSolid = Color(lsHex: 0x111111)
        p.deep = Color(lsHex: 0x3A3A3A)
        p.heroBg = Color(lsHex: 0xFFCD00)
        p.heroFg = Color(lsHex: 0x111111)
        p.navBg = Color(lsHex: 0x000000)
        p.navSub = Color(lsHex: 0xBDBDBD)
        p.segOn = Color(lsHex: 0x474747)
        return p
    }()

    // The made-up example school, to show that a different email loads different colors.
    static let blueLight = LSPalette(id: "blue", bg: 0xDCE8F7, ink: 0x12284A, sub: 0x4E5D73, tint: 0xE6EEF9,
                                     line: 0xC5D3E8, rule: 0xEAF0F8, strong: 0x8194B0, check: 0x6F82A0,
                                     accent: 0x1F5FA8, word: 0x174A85, h1: 0xC9D7EC, h2: 0xE6EEF9)

    static let blueDark: LSPalette = {
        var p = LSPalette(id: "blue", bg: 0x0C131F, card: 0x162030, ink: 0xEAF0F8, sub: 0xA6B4C8, tint: 0x22304A,
                          line: 0x2A3A54, rule: 0x202D42, strong: 0x667B99, check: 0x8799B6,
                          accent: 0x7FB2F2, word: 0x9CC4F6, h1: 0xD9E4F3, h2: 0xE6EEF9)
        p.onAccent = Color(lsHex: 0x0C131F)
        p.onAccentInk = Color(lsHex: 0x0C131F)
        p.solid = Color(lsHex: 0x7FB2F2)
        p.onSolid = Color(lsHex: 0x0C131F)
        p.deep = Color(lsHex: 0x2C3C56)
        p.heroBg = Color(lsHex: 0x1F5FA8)
        p.heroFg = Color.white
        p.segOn = Color(lsHex: 0x34476A)
        return p
    }()

    /// The palette for a theme name from schools.csv, in its light or dark version.
    static func named(_ id: String, dark: Bool) -> LSPalette {
        switch id {
        case "mtu": return dark ? mtuDark : mtuLight
        case "blue": return dark ? blueDark : blueLight
        default: return purple
        }
    }
}

extension LSStore {
    /// The colors for the signed-in student's school. Screens write store.p.ink, store.p.accent, ...
    var p: LSPalette { LSPalette.named(themeID, dark: isDark) }
}

extension Font {
    /// Shorthand: .ls(15, .bold)
    static func ls(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight)
    }
}

// MARK: - Buttons

/// Makes a button shrink slightly while it is pressed.
struct LSPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// The big filled button, e.g. "Save task". Pass soft: true for the lighter version.
struct LSBigButton: View {
    @EnvironmentObject var store: LSStore
    let title: String
    var icon: String? = nil
    var soft: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon).font(.ls(16, .bold))
                }
                Text(title).font(.ls(16, .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(soft ? store.p.ink : store.p.onAccent)
            .background(soft ? store.p.tint : store.p.accent)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(LSPressStyle())
    }
}

/// A pill that can be on or off: filters, days, task types.
struct LSChip: View {
    @EnvironmentObject var store: LSStore
    let label: String
    let on: Bool
    var dot: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let dot = dot {
                    Circle().fill(dot).frame(width: 10, height: 10)
                }
                Text(label).font(.ls(14, .semibold))
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .foregroundStyle(on ? store.p.onSolid : store.p.ink)
            .background(on ? store.p.solid : store.p.card)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(on ? store.p.solid : store.p.strong, lineWidth: 1.5))
        }
        .buttonStyle(LSPressStyle())
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

/// A row of chips that scrolls sideways, edge to edge.
struct LSChipRow<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                content
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
    }
}

/// The switch between views at the top of a tab, e.g. Directory / Departments / Student orgs.
struct LSSegmented: View {
    @EnvironmentObject var store: LSStore
    let items: [(id: String, label: String)]
    let selected: String
    let onPick: (String) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.id) { item in
                let on = item.id == selected
                Button {
                    onPick(item.id)
                } label: {
                    Text(item.label)
                        .font(.ls(14, on ? .bold : .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(on ? store.p.segOn : Color.clear)
                                .shadow(color: on ? Color.black.opacity(0.14) : Color.clear, radius: 1.5, x: 0, y: 1)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(LSPressStyle())
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(4)
        .background(store.p.tint)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Containers

/// The white rounded box most content sits in.
struct LSCard<Content: View>: View {
    @EnvironmentObject var store: LSStore
    let padding: CGFloat
    let radius: CGFloat
    let content: Content

    init(padding: CGFloat = 16, radius: CGFloat = 22, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.radius = radius
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(store.p.card)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(store.p.line, lineWidth: 1))
    }
}

/// The thin line between rows inside a card.
struct LSRule: View {
    @EnvironmentObject var store: LSStore

    var body: some View {
        Rectangle().fill(store.p.rule).frame(height: 1)
    }
}

/// Small all-caps label above a group.
struct LSCaps: View {
    @EnvironmentObject var store: LSStore
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.ls(12, .bold))
            .tracking(1)
            .foregroundStyle(store.p.sub)
    }
}

/// Big screen title, e.g. "Dashboard".
struct LSTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.ls(36, .heavy))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Heading inside a screen, e.g. "Quick links".
struct LSHeading: View {
    let text: String
    var size: CGFloat = 19

    var body: some View {
        Text(text).font(.ls(size, .bold))
    }
}

/// White card shown when a list has nothing in it.
struct LSEmptyCard: View {
    @EnvironmentObject var store: LSStore
    let title: String
    let sub: String

    var body: some View {
        LSCard(padding: 20) {
            Text(title).font(.ls(19, .bold))
            Text(sub).font(.ls(14)).foregroundStyle(store.p.sub).padding(.top, 6)
        }
    }
}

/// "‹ All departments" style back button at the top of a detail page.
struct LSBackButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left").font(.ls(14, .bold))
                Text(label).font(.ls(14, .bold))
            }
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(LSPressStyle())
    }
}

/// Search box with a magnifying glass.
struct LSSearchField: View {
    @EnvironmentObject var store: LSStore
    let placeholder: String
    @Binding var text: String
    var bold: Bool = false
    var autoFocus: Bool = false     // true = bring up the keyboard as soon as the box appears
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").font(.ls(18, .semibold))
            TextField(placeholder, text: $text)
                .font(.ls(16))
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .autocorrectionDisabled(true)
                .submitLabel(.search)
                .focused($focused)
                .task {
                    if autoFocus {
                        try? await Task.sleep(nanoseconds: 350_000_000)
                        focused = true
                    }
                }
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.ls(17))
                        .foregroundStyle(store.p.sub)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(store.p.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(bold ? store.p.ink : store.p.strong, lineWidth: bold ? 2 : 1.5)
        )
    }
}

/// Label on the left, value on the right: Location / Hours / Email ...
struct LSInfoRows: View {
    @EnvironmentObject var store: LSStore
    let rows: [(label: String, value: String)]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 {
                    LSRule()
                }
                HStack(alignment: .center, spacing: 16) {
                    Text(row.label)
                        .font(.ls(13.5))
                        .foregroundStyle(store.p.sub)
                    Spacer(minLength: 0)
                    Text(row.value)
                        .font(.ls(14.5, .semibold))
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                }
                .padding(.vertical, 8)
                .frame(minHeight: 54)
            }
        }
        .padding(.horizontal, 16)
        .background(store.p.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(store.p.line, lineWidth: 1))
    }
}

/// A tappable row with a title, a smaller line under it, and a chevron.
struct LSNavRow: View {
    @EnvironmentObject var store: LSStore
    let title: String
    let sub: String
    var chevron: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.ls(15, .bold))
                        .multilineTextAlignment(.leading)
                    if !sub.isEmpty {
                        Text(sub)
                            .font(.ls(13))
                            .foregroundStyle(store.p.sub)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 0)
                if chevron {
                    Image(systemName: "chevron.right")
                        .font(.ls(14, .semibold))
                        .foregroundStyle(store.p.sub)
                }
            }
            .padding(.vertical, 6)
            .frame(minHeight: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(LSPressStyle())
    }
}

/// A person in a list: round initials badge, name, and their role.
struct LSPersonRow: View {
    @EnvironmentObject var store: LSStore
    let person: LSPerson
    var showDept: Bool = true
    var chevron: Bool = true

    var body: some View {
        Button {
            store.openContact(person)
        } label: {
            HStack(spacing: 12) {
                Text(person.initials)
                    .font(.ls(14, .bold))
                    .frame(width: 44, height: 44)
                    .background(store.p.tint)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(person.name).font(.ls(15, .bold))
                    Text(showDept ? person.role + " · " + person.dept : person.role)
                        .font(.ls(13))
                        .foregroundStyle(store.p.sub)
                        .lineLimit(showDept ? 1 : 2)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                if chevron {
                    Image(systemName: "chevron.right")
                        .font(.ls(14, .semibold))
                        .foregroundStyle(store.p.sub)
                }
            }
            .padding(.vertical, 6)
            .frame(minHeight: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(LSPressStyle())
    }
}

/// Opens a web page in the phone's browser. Draws nothing if the address is not valid.
struct LSWebButton: View {
    @EnvironmentObject var store: LSStore
    let title: String
    let address: String
    var filled: Bool = false

    var body: some View {
        if let url = URL(string: address), !address.isEmpty {
            Link(destination: url) {
                HStack {
                    Text(title).font(.ls(15, .bold))
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right").font(.ls(14, .bold))
                }
                .padding(.horizontal, 18)
                .frame(height: 52)
                .foregroundStyle(filled ? store.p.onAccent : store.p.ink)
                .background(filled ? store.p.accent : store.p.tint)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .accessibilityHint("Opens in browser")
        }
    }
}

// MARK: - Student org logos

/// All the org logos are stored in one big image (org-logos.webp). This cuts out one logo at a time.
final class LSLogoSheet {
    static let shared = LSLogoSheet()

    private let sheet: CGImage?
    private var cache: [Int: CGImage] = [:]

    private init() {
        sheet = LSLogoSheet.loadSheet()
    }

    /// Reads the big logo image from the app bundle.
    private static func loadSheet() -> CGImage? {
        #if canImport(ImageIO)
        guard let url = LSCSV.bundleURL("org-logos", "webp"),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
        #else
        return nil
        #endif
    }

    func logo(at index: Int, columns: Int, cell: Int) -> CGImage? {
        if let cached = cache[index] {
            return cached
        }
        guard index >= 0, columns > 0, let source = sheet else { return nil }
        let rect = CGRect(x: (index % columns) * cell, y: (index / columns) * cell, width: cell, height: cell)
        guard let cut = source.cropping(to: rect) else { return nil }
        cache[index] = cut
        return cut
    }
}

/// An org's logo, or its initials on a soft square when it has no logo.
struct LSOrgLogo: View {
    @EnvironmentObject var store: LSStore
    let org: LSOrg
    let size: CGFloat
    var corner: CGFloat? = nil      // leave empty for the usual rounding

    private var initials: String {
        let source = org.shortName.isEmpty ? org.name : org.shortName
        let lettersAndDigits = source.filter { $0.isLetter || $0.isNumber }
        return String(lettersAndDigits.prefix(2)).uppercased()
    }

    var body: some View {
        let corner = self.corner ?? size * 0.26
        Group {
            if let image = LSLogoSheet.shared.logo(at: org.logoIndex, columns: store.data.logoColumns, cell: store.data.logoCell) {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(initials)
                    .font(.ls(size * 0.29, .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(store.p.tint)
            }
        }
        .frame(width: size, height: size)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: corner, style: .continuous).stroke(store.p.line, lineWidth: 1))
        .accessibilityHidden(true)
    }
}
