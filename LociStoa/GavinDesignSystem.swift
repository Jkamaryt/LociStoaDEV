import SwiftUI

// MARK: - Theme System (Exact match to Main.dc.html .th-purple, .th-blue, .th-green, .th-copper)
enum LociTheme: String, CaseIterable, Codable, Identifiable {
    case purple = "purple"
    case blue = "blue"
    case green = "green"
    case copper = "copper"
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .purple: return "Purple"
        case .blue: return "Blue"
        case .green: return "Green"
        case .copper: return "Copper"
        }
    }
    
    var swatch: Color {
        switch self {
        case .purple: return Color(hex: 0x734FC2)
        case .blue:   return Color(hex: 0x1F5FA8)
        case .green:  return Color(hex: 0x1E6B4E)
        case .copper: return Color(hex: 0xA84B22)
        }
    }
    
    var bg: Color {
        switch self {
        case .purple: return Color(hex: 0xD9D9FF)
        case .blue:   return Color(hex: 0xDCE8F7)
        case .green:  return Color(hex: 0xDDEBE3)
        case .copper: return Color(hex: 0xF2F4F6)
        }
    }
    
    var ink: Color {
        switch self {
        case .purple: return Color(hex: 0x2B1F52)
        case .blue:   return Color(hex: 0x12284A)
        case .green:  return Color(hex: 0x12332A)
        case .copper: return Color(hex: 0x10202B)
        }
    }
    
    var sub: Color {
        switch self {
        case .purple: return Color(hex: 0x5E5873)
        case .blue:   return Color(hex: 0x4E5D73)
        case .green:  return Color(hex: 0x4D6259)
        case .copper: return Color(hex: 0x51606B)
        }
    }
    
    var tint: Color {
        switch self {
        case .purple: return Color(hex: 0xECE7FB)
        case .blue:   return Color(hex: 0xE6EEF9)
        case .green:  return Color(hex: 0xE6F1EB)
        case .copper: return Color(hex: 0xE6ECF0)
        }
    }
    
    var line: Color {
        switch self {
        case .purple: return Color(hex: 0xCFCBEE)
        case .blue:   return Color(hex: 0xC5D3E8)
        case .green:  return Color(hex: 0xC4D8CD)
        case .copper: return Color(hex: 0xE1E6EA)
        }
    }
    
    var rule: Color {
        switch self {
        case .purple: return Color(hex: 0xEEEBFA)
        case .blue:   return Color(hex: 0xEAF0F8)
        case .green:  return Color(hex: 0xEAF3EE)
        case .copper: return Color(hex: 0xEEF1F4)
        }
    }
    
    var strong: Color {
        switch self {
        case .purple: return Color(hex: 0xBDB6E0)
        case .blue:   return Color(hex: 0xAFC0DA)
        case .green:  return Color(hex: 0xAEC7BA)
        case .copper: return Color(hex: 0xC9D2D9)
        }
    }
    
    var check: Color {
        switch self {
        case .purple: return Color(hex: 0x7A6FA6)
        case .blue:   return Color(hex: 0x6F82A0)
        case .green:  return Color(hex: 0x6B8A7C)
        case .copper: return Color(hex: 0x7D8B95)
        }
    }
    
    var accent: Color {
        switch self {
        case .purple: return Color(hex: 0x734FC2)
        case .blue:   return Color(hex: 0x1F5FA8)
        case .green:  return Color(hex: 0x1E6B4E)
        case .copper: return Color(hex: 0xA84B22)
        }
    }
    
    var word: Color {
        switch self {
        case .purple: return Color(hex: 0x4A2F96)
        case .blue:   return Color(hex: 0x174A85)
        case .green:  return Color(hex: 0x17533C)
        case .copper: return Color(hex: 0xA84B22)
        }
    }
    
    var h1: Color {
        switch self {
        case .purple: return Color(hex: 0xD6CFF2)
        case .blue:   return Color(hex: 0xC9D7EC)
        case .green:  return Color(hex: 0xC7DCD1)
        case .copper: return Color(hex: 0xC3CED6)
        }
    }
    
    var h2: Color {
        switch self {
        case .purple: return Color(hex: 0xEDE9FB)
        case .blue:   return Color(hex: 0xE6EEF9)
        case .green:  return Color(hex: 0xE4F0EA)
        case .copper: return Color(hex: 0xE3EAEE)
        }
    }
    
    var sk2: Color {
        switch self {
        case .purple: return Color(hex: 0xF6F3FF)
        case .blue:   return Color(hex: 0xF3F7FC)
        case .green:  return Color(hex: 0xF2F8F5)
        case .copper: return Color(hex: 0xF4F7F9)
        }
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

// MARK: - Typography Helpers (Bricolage Grotesque & Inter Equivalents)
enum LociFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    
    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Press Animation ButtonStyle (.press:active { transform: scale(.97) })
struct LociPressButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Shimmer Skeleton Box (.sk)
struct LociShimmerBox: View {
    let theme: LociTheme
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat
    
    @State private var phase: CGFloat = -1.0
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                theme.tint
                LinearGradient(
                    stops: [
                        .init(color: theme.tint, location: 0.0),
                        .init(color: theme.sk2, location: 0.5),
                        .init(color: theme.tint, location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: w * 1.5)
                .offset(x: phase * w * 1.5)
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                phase = 1.0
            }
        }
    }
}

// MARK: - Flow Layout (Replicates display: flex; flex-wrap: wrap; gap: 8px)
struct LociFlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX > 0 && currentX + size.width > maxWidth {
                currentX = 0
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }
        
        return CGSize(width: proposal.width ?? totalWidth, height: currentY + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX > bounds.minX && currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}

// MARK: - Custom Vector Icons Matching Main.dc.html SVGs
enum LociIconKind: String {
    case home
    case people
    case map
    case planner
    case more
    case help
    case link
    case clock
    case phone
    case flag
    case chevronRight
    case chevronLeft
    case externalArrow
    case search
    case check
    case plus
    case close
    case mail
    case mapPin
    case star
    case chat
    case briefcase
    case book
    case settings
    case trash
    case refresh
}

struct LociIcon: View {
    let kind: LociIconKind
    var size: CGFloat = 20
    var lineWidth: CGFloat = 2.0
    var color: Color = .primary
    var filled: Bool = false
    
    var body: some View {
        Canvas { context, canvasSize in
            let scaleX = canvasSize.width / 24.0
            let scaleY = canvasSize.height / 24.0
            var ctx = context
            ctx.scaleBy(x: scaleX, y: scaleY)
            
            let path = iconPath(for: kind)
            let style = StrokeStyle(
                lineWidth: lineWidth,
                lineCap: .round,
                lineJoin: .round
            )
            if filled {
                ctx.fill(path, with: .color(color))
            }
            ctx.stroke(path, with: .color(color), style: style)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
    
    private func iconPath(for kind: LociIconKind) -> Path {
        var p = Path()
        switch kind {
        case .home:
            // M3 10.5 12 3l9 7.5M5 9.5V21h14V9.5
            p.move(to: CGPoint(x: 3, y: 10.5))
            p.addLine(to: CGPoint(x: 12, y: 3))
            p.addLine(to: CGPoint(x: 21, y: 10.5))
            p.move(to: CGPoint(x: 5, y: 9.5))
            p.addLine(to: CGPoint(x: 5, y: 21))
            p.addLine(to: CGPoint(x: 19, y: 21))
            p.addLine(to: CGPoint(x: 19, y: 9.5))
            
        case .people:
            // M12.5 8a3.5 3.5 0 1 1-7 0 3.5 3.5 0 0 1 7 0zM2.5 20c.8-3.5 3.4-5.5 6.5-5.5s5.7 2 6.5 5.5M16 4.6a3.5 3.5 0 0 1 0 6.8M18 14.8c1.8.7 3 2.5 3.5 5.2
            p.addEllipse(in: CGRect(x: 5.5, y: 4.5, width: 7, height: 7))
            p.move(to: CGPoint(x: 2.5, y: 20))
            p.addCurve(to: CGPoint(x: 9, y: 14.5), control1: CGPoint(x: 3.3, y: 16.5), control2: CGPoint(x: 5.9, y: 14.5))
            p.addCurve(to: CGPoint(x: 15.5, y: 20), control1: CGPoint(x: 12.1, y: 14.5), control2: CGPoint(x: 14.7, y: 16.5))
            p.move(to: CGPoint(x: 16, y: 4.6))
            p.addCurve(to: CGPoint(x: 16, y: 11.4), control1: CGPoint(x: 19.2, y: 5.4), control2: CGPoint(x: 19.2, y: 10.6))
            p.move(to: CGPoint(x: 18, y: 14.8))
            p.addCurve(to: CGPoint(x: 21.5, y: 20), control1: CGPoint(x: 19.8, y: 15.5), control2: CGPoint(x: 21, y: 17.3))
            
        case .map:
            // M9 4 3 6v14l6-2 6 2 6-2V4l-6 2-6-2zM9 4v14M15 6v14
            p.move(to: CGPoint(x: 9, y: 4))
            p.addLine(to: CGPoint(x: 3, y: 6))
            p.addLine(to: CGPoint(x: 3, y: 20))
            p.addLine(to: CGPoint(x: 9, y: 18))
            p.addLine(to: CGPoint(x: 15, y: 20))
            p.addLine(to: CGPoint(x: 21, y: 18))
            p.addLine(to: CGPoint(x: 21, y: 4))
            p.addLine(to: CGPoint(x: 15, y: 6))
            p.closeSubpath()
            p.move(to: CGPoint(x: 9, y: 4))
            p.addLine(to: CGPoint(x: 9, y: 18))
            p.move(to: CGPoint(x: 15, y: 6))
            p.addLine(to: CGPoint(x: 15, y: 20))
            
        case .planner:
            // M6 3h12a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2zM8 9l1.5 1.5L12 8M8 15h8
            p.addRoundedRect(in: CGRect(x: 4, y: 3, width: 16, height: 18), cornerSize: CGSize(width: 2, height: 2))
            p.move(to: CGPoint(x: 8, y: 9))
            p.addLine(to: CGPoint(x: 9.5, y: 10.5))
            p.addLine(to: CGPoint(x: 12, y: 8))
            p.move(to: CGPoint(x: 8, y: 15))
            p.addLine(to: CGPoint(x: 16, y: 15))
            
        case .more:
            // M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM14 14h6v6h-6z
            p.addRect(CGRect(x: 4, y: 4, width: 6, height: 6))
            p.addRect(CGRect(x: 14, y: 4, width: 6, height: 6))
            p.addRect(CGRect(x: 4, y: 14, width: 6, height: 6))
            p.addRect(CGRect(x: 14, y: 14, width: 6, height: 6))
            
        case .help:
            // M9 3h6v5H9zM3 16h6v5H3zM15 16h6v5h-6zM12 8v4M6 16v-4h12v4
            p.addRect(CGRect(x: 9, y: 3, width: 6, height: 5))
            p.addRect(CGRect(x: 3, y: 16, width: 6, height: 5))
            p.addRect(CGRect(x: 15, y: 16, width: 6, height: 5))
            p.move(to: CGPoint(x: 12, y: 8))
            p.addLine(to: CGPoint(x: 12, y: 12))
            p.move(to: CGPoint(x: 6, y: 16))
            p.addLine(to: CGPoint(x: 6, y: 12))
            p.addLine(to: CGPoint(x: 18, y: 12))
            p.addLine(to: CGPoint(x: 18, y: 16))
            
        case .link:
            // M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1
            p.move(to: CGPoint(x: 10, y: 14))
            p.addCurve(to: CGPoint(x: 15.7, y: 14), control1: CGPoint(x: 11.6, y: 15.6), control2: CGPoint(x: 14.1, y: 15.6))
            p.addLine(to: CGPoint(x: 18.7, y: 11))
            p.addCurve(to: CGPoint(x: 13, y: 5.3), control1: CGPoint(x: 20.3, y: 9.4), control2: CGPoint(x: 14.6, y: 3.7))
            p.addLine(to: CGPoint(x: 12, y: 6.3))
            
            p.move(to: CGPoint(x: 14, y: 10))
            p.addCurve(to: CGPoint(x: 8.3, y: 10), control1: CGPoint(x: 12.4, y: 8.4), control2: CGPoint(x: 9.9, y: 8.4))
            p.addLine(to: CGPoint(x: 5.3, y: 13))
            p.addCurve(to: CGPoint(x: 11, y: 18.7), control1: CGPoint(x: 3.7, y: 14.6), control2: CGPoint(x: 9.4, y: 20.3))
            p.addLine(to: CGPoint(x: 12, y: 17.7))
            
        case .clock:
            // M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0zM12 7v5l3 2
            p.addEllipse(in: CGRect(x: 3, y: 3, width: 18, height: 18))
            p.move(to: CGPoint(x: 12, y: 7))
            p.addLine(to: CGPoint(x: 12, y: 12))
            p.addLine(to: CGPoint(x: 15, y: 14))
            
        case .phone:
            // M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L15 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2z
            p.move(to: CGPoint(x: 5, y: 4))
            p.addLine(to: CGPoint(x: 9, y: 4))
            p.addLine(to: CGPoint(x: 11, y: 9))
            p.addLine(to: CGPoint(x: 8.5, y: 10.5))
            p.addCurve(to: CGPoint(x: 13.5, y: 15.5), control1: CGPoint(x: 9.5, y: 13), control2: CGPoint(x: 11, y: 14.5))
            p.addLine(to: CGPoint(x: 15, y: 13))
            p.addLine(to: CGPoint(x: 20, y: 15))
            p.addLine(to: CGPoint(x: 20, y: 19))
            p.addCurve(to: CGPoint(x: 18, y: 21), control1: CGPoint(x: 20, y: 20.1), control2: CGPoint(x: 19.1, y: 21))
            p.addCurve(to: CGPoint(x: 3, y: 6), control1: CGPoint(x: 9.7, y: 21), control2: CGPoint(x: 3, y: 14.3))
            p.addCurve(to: CGPoint(x: 5, y: 4), control1: CGPoint(x: 3, y: 4.9), control2: CGPoint(x: 3.9, y: 4))
            p.closeSubpath()
            
        case .flag:
            // M5 21V4M5 4h12l-2 4 2 4H5
            p.move(to: CGPoint(x: 5, y: 21))
            p.addLine(to: CGPoint(x: 5, y: 4))
            p.move(to: CGPoint(x: 5, y: 4))
            p.addLine(to: CGPoint(x: 17, y: 4))
            p.addLine(to: CGPoint(x: 15, y: 8))
            p.addLine(to: CGPoint(x: 17, y: 12))
            p.addLine(to: CGPoint(x: 5, y: 12))
            
        case .chevronRight:
            // m9 6 6 6-6 6
            p.move(to: CGPoint(x: 9, y: 6))
            p.addLine(to: CGPoint(x: 15, y: 12))
            p.addLine(to: CGPoint(x: 9, y: 18))
            
        case .chevronLeft:
            // m15 6-6 6 6 6
            p.move(to: CGPoint(x: 15, y: 6))
            p.addLine(to: CGPoint(x: 9, y: 12))
            p.addLine(to: CGPoint(x: 15, y: 18))
            
        case .externalArrow:
            // M7 17 17 7M8 7h9v9
            p.move(to: CGPoint(x: 7, y: 17))
            p.addLine(to: CGPoint(x: 17, y: 7))
            p.move(to: CGPoint(x: 8, y: 7))
            p.addLine(to: CGPoint(x: 17, y: 7))
            p.addLine(to: CGPoint(x: 17, y: 16))
            
        case .search:
            // M18 11a7 7 0 1 1-14 0 7 7 0 0 1 14 0zM20 20l-3.5-3.5
            p.addEllipse(in: CGRect(x: 4, y: 4, width: 14, height: 14))
            p.move(to: CGPoint(x: 20, y: 20))
            p.addLine(to: CGPoint(x: 16.5, y: 16.5))
            
        case .check:
            // m5 12.5 4.5 4.5L19 7.5
            p.move(to: CGPoint(x: 5, y: 12.5))
            p.addLine(to: CGPoint(x: 9.5, y: 17))
            p.addLine(to: CGPoint(x: 19, y: 7.5))
            
        case .plus:
            // M12 5v14M5 12h14
            p.move(to: CGPoint(x: 12, y: 5))
            p.addLine(to: CGPoint(x: 12, y: 19))
            p.move(to: CGPoint(x: 5, y: 12))
            p.addLine(to: CGPoint(x: 19, y: 12))
            
        case .close:
            // M6 6l12 12M18 6 6 18
            p.move(to: CGPoint(x: 6, y: 6))
            p.addLine(to: CGPoint(x: 18, y: 18))
            p.move(to: CGPoint(x: 18, y: 6))
            p.addLine(to: CGPoint(x: 6, y: 18))
            
        case .mail:
            // M3 6h18v12H3zM3 7l9 6 9-6
            p.addRect(CGRect(x: 3, y: 6, width: 18, height: 12))
            p.move(to: CGPoint(x: 3, y: 7))
            p.addLine(to: CGPoint(x: 12, y: 13))
            p.addLine(to: CGPoint(x: 21, y: 7))
            
        case .mapPin:
            // M12 21s-7-6.2-7-11.5a7 7 0 0 1 14 0C19 14.8 12 21 12 21zM14.5 9.5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z
            p.move(to: CGPoint(x: 12, y: 21))
            p.addCurve(to: CGPoint(x: 5, y: 9.5), control1: CGPoint(x: 12, y: 21), control2: CGPoint(x: 5, y: 14.8))
            p.addArc(center: CGPoint(x: 12, y: 9.5), radius: 7, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            p.addCurve(to: CGPoint(x: 12, y: 21), control1: CGPoint(x: 19, y: 14.8), control2: CGPoint(x: 12, y: 21))
            p.closeSubpath()
            p.addEllipse(in: CGRect(x: 9.5, y: 7, width: 5, height: 5))
            
        case .star:
            // M12 3.5l2.6 5.3 5.9.9-4.3 4.1 1 5.8L12 16.9 6.8 19.6l1-5.8L3.5 9.7l5.9-.9z
            p.move(to: CGPoint(x: 12, y: 3.5))
            p.addLine(to: CGPoint(x: 14.6, y: 8.8))
            p.addLine(to: CGPoint(x: 20.5, y: 9.7))
            p.addLine(to: CGPoint(x: 16.2, y: 13.8))
            p.addLine(to: CGPoint(x: 17.2, y: 19.6))
            p.addLine(to: CGPoint(x: 12, y: 16.9))
            p.addLine(to: CGPoint(x: 6.8, y: 19.6))
            p.addLine(to: CGPoint(x: 7.8, y: 13.8))
            p.addLine(to: CGPoint(x: 3.5, y: 9.7))
            p.addLine(to: CGPoint(x: 9.4, y: 8.8))
            p.closeSubpath()
            
        case .chat:
            // Speech bubble
            p.addRoundedRect(in: CGRect(x: 3, y: 4, width: 18, height: 13), cornerSize: CGSize(width: 3, height: 3))
            p.move(to: CGPoint(x: 8, y: 17))
            p.addLine(to: CGPoint(x: 6, y: 21))
            p.addLine(to: CGPoint(x: 12, y: 17))
            p.move(to: CGPoint(x: 8, y: 9))
            p.addLine(to: CGPoint(x: 16, y: 9))
            p.move(to: CGPoint(x: 8, y: 13))
            p.addLine(to: CGPoint(x: 13, y: 13))
            
        case .briefcase:
            // Briefcase for Career Fair
            p.addRoundedRect(in: CGRect(x: 3, y: 7, width: 18, height: 13), cornerSize: CGSize(width: 2, height: 2))
            p.move(to: CGPoint(x: 9, y: 7))
            p.addLine(to: CGPoint(x: 9, y: 5))
            p.addLine(to: CGPoint(x: 15, y: 5))
            p.addLine(to: CGPoint(x: 15, y: 7))
            p.move(to: CGPoint(x: 3, y: 12))
            p.addLine(to: CGPoint(x: 21, y: 12))
            
        case .book:
            // Book / Nomenclature
            p.move(to: CGPoint(x: 4, y: 5))
            p.addLine(to: CGPoint(x: 12, y: 7))
            p.addLine(to: CGPoint(x: 20, y: 5))
            p.addLine(to: CGPoint(x: 20, y: 18))
            p.addLine(to: CGPoint(x: 12, y: 20))
            p.addLine(to: CGPoint(x: 4, y: 18))
            p.closeSubpath()
            p.move(to: CGPoint(x: 12, y: 7))
            p.addLine(to: CGPoint(x: 12, y: 20))
            
        case .settings:
            // Gear / Sliders
            p.addEllipse(in: CGRect(x: 8.5, y: 8.5, width: 7, height: 7))
            p.addEllipse(in: CGRect(x: 4, y: 4, width: 16, height: 16))
            
        case .trash:
            // Trash can
            p.move(to: CGPoint(x: 4, y: 7))
            p.addLine(to: CGPoint(x: 20, y: 7))
            p.move(to: CGPoint(x: 9, y: 7))
            p.addLine(to: CGPoint(x: 9, y: 4))
            p.addLine(to: CGPoint(x: 15, y: 4))
            p.addLine(to: CGPoint(x: 15, y: 7))
            p.move(to: CGPoint(x: 6, y: 7))
            p.addLine(to: CGPoint(x: 7, y: 20))
            p.addLine(to: CGPoint(x: 17, y: 20))
            p.addLine(to: CGPoint(x: 18, y: 7))
            
        case .refresh:
            // Circular refresh arrow
            p.addArc(center: CGPoint(x: 12, y: 12), radius: 8, startAngle: .degrees(30), endAngle: .degrees(320), clockwise: false)
            p.move(to: CGPoint(x: 16, y: 4))
            p.addLine(to: CGPoint(x: 20, y: 6.5))
            p.addLine(to: CGPoint(x: 16.5, y: 9.5))
        }
        return p
    }
}

// MARK: - Decorative Wave SVG on Home "Next Class" Hero Card
struct LociHeroWavesDecoration: View {
    var body: some View {
        Canvas { context, _ in
            let style = StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round)
            let curves: [(CGPoint, CGPoint, CGPoint, CGPoint, CGPoint, CGPoint, CGPoint)] = [
                // M20 120c30-50 80-70 130-60s80 50 90 90
                (CGPoint(x: 20, y: 120), CGPoint(x: 50, y: 70), CGPoint(x: 100, y: 50), CGPoint(x: 150, y: 60),
                 CGPoint(x: 200, y: 70), CGPoint(x: 230, y: 110), CGPoint(x: 240, y: 150)),
                // M40 130c26-40 66-56 108-48s66 40 74 72
                (CGPoint(x: 40, y: 130), CGPoint(x: 66, y: 90), CGPoint(x: 106, y: 74), CGPoint(x: 148, y: 82),
                 CGPoint(x: 190, y: 90), CGPoint(x: 214, y: 122), CGPoint(x: 222, y: 154)),
                // M62 140c20-30 50-42 84-36s52 30 58 54
                (CGPoint(x: 62, y: 140), CGPoint(x: 82, y: 110), CGPoint(x: 112, y: 98), CGPoint(x: 146, y: 104),
                 CGPoint(x: 180, y: 110), CGPoint(x: 198, y: 134), CGPoint(x: 204, y: 158)),
                // M86 150c14-20 34-28 58-24s38 20 42 36
                (CGPoint(x: 86, y: 150), CGPoint(x: 100, y: 130), CGPoint(x: 120, y: 122), CGPoint(x: 144, y: 126),
                 CGPoint(x: 168, y: 130), CGPoint(x: 182, y: 146), CGPoint(x: 186, y: 162)),
                // M112 158c8-10 20-14 32-12s22 10 24 20
                (CGPoint(x: 112, y: 158), CGPoint(x: 120, y: 148), CGPoint(x: 132, y: 144), CGPoint(x: 144, y: 146),
                 CGPoint(x: 156, y: 148), CGPoint(x: 166, y: 156), CGPoint(x: 168, y: 166))
            ]
            var path = Path()
            for c in curves {
                path.move(to: c.0)
                path.addCurve(to: c.3, control1: c.1, control2: c.2)
                path.addCurve(to: c.6, control1: c.4, control2: c.5)
            }
            context.stroke(path, with: .color(.white.opacity(0.13)), style: style)
        }
        .frame(width: 260, height: 200)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
