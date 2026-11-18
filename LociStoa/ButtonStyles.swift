import SwiftUI

struct ModernButtonStyle: ButtonStyle {
    var backgroundColor: Color = lociAccent
    var foregroundColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LociFont.sans(16, weight: .bold))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .padding(.horizontal, 20)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// A smaller version for inline buttons (like the Map floors)
struct ModernCompactButtonStyle: ButtonStyle {
    var backgroundColor: Color = lociAccent
    var foregroundColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LociFont.sans(15, weight: .bold))
            .frame(minWidth: 72, minHeight: 44)
            .padding(.horizontal, 14)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
