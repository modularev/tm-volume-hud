import SwiftUI

struct HUDView: View {
    let dbValue: String
    let rawValue: Double
    let theme: HUDTheme
    let port: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(theme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(LinearGradient(colors: [.white.opacity(0.15), .black.opacity(0.4)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )

            VStack(spacing: 6) {
                HStack {
                    Text("VOLUME MONITOR")
                        .font(.custom("ShareTechMono-Regular", size: 10))
                        .foregroundColor(theme == .light ? .black : .white)
                    Spacer()
                    Text("PORT: \(String(port))")
                        .font(.custom("ShareTechMono-Regular", size: 9))
                        .foregroundColor(theme.foreground.opacity(0.5))
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)

                VStack(spacing: 0) {
                    Text("MAIN OUT")
                        .font(.custom("Michroma", size: 12))
                        .tracking(2.0)
                        .foregroundColor(theme.foreground.opacity(0.5))
                        .padding(.top, 6)
                    
                    Text(dbValue)
                        .font(.custom("Michroma", size: 48))
                        .foregroundColor(theme.foreground)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    SegmentedMeterView(rawValue: rawValue, theme: theme)
                        .padding(.top, 6)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.25))
                .cornerRadius(2)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
    }
}

struct SegmentedMeterView: View {
    let rawValue: Double
    let theme: HUDTheme
    let totalSegments = 71
    let segmentWidth: CGFloat = 3.0
    let spacing: CGFloat = 1.0
    
    var totalWidth: CGFloat {
        CGFloat(totalSegments) * (segmentWidth + spacing) - spacing
    }
    
    var activeSegments: Int {
        if rawValue <= -64.5 { return 0 }
        
        let clamped = max(-64.5, min(6, rawValue))
        return Int(floor(clamped + 65.5))
    }
    
    func positionFor(index: Int) -> CGFloat {
        let segmentOffset = CGFloat(index) * (segmentWidth + spacing)
        return segmentOffset + (segmentWidth / 2)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: spacing) {
                ForEach(0..<totalSegments, id: \.self) { i in
                    Rectangle()
                        .fill(getSegmentColor(index: i))
                        .frame(width: segmentWidth, height: 10)
                }
            }
            
            ZStack(alignment: .trailing) {
                LabelView(text: "∞", x: positionFor(index: 0), isBold: false)
                LabelView(text: "50", x: positionFor(index: 14), isBold: false)
                LabelView(text: "40", x: positionFor(index: 24), isBold: false)
                LabelView(text: "30", x: positionFor(index: 34), isBold: false)
                LabelView(text: "20", x: positionFor(index: 44), isBold: false)
                LabelView(text: "10", x: positionFor(index: 54), isBold: false)
                LabelView(text: "0", x: positionFor(index: 64), isBold: true)
            }
            .foregroundColor(theme.foreground.opacity(0.4))
            .frame(width: totalWidth, height: 10, alignment: .trailing)
        }
    }
    
    private func getSegmentColor(index: Int) -> Color {
        let isActive = index < activeSegments
        let activeOpacity: Double = 1.0
        let inactiveOpacity: Double = 0.12 // Slightly higher than 0.08 for better visibility on all themes
        
        let baseColor: Color
        
        if index >= 65 {
            baseColor = theme.critical
        } else if index >= 45 {
            baseColor = theme.warning
        } else {
            baseColor = theme.foreground
        }
        
        return baseColor.opacity(isActive ? activeOpacity : inactiveOpacity)
    }
    
    struct LabelView: View {
        let text: String
        let x: CGFloat
        let isBold: Bool
        
        var body: some View {
            Text(text)
                .font(.custom("ShareTechMono-Regular", size: isBold ? 12 : 10))
                .fixedSize()
                .position(x: x, y: 5)
        }
    }
}
