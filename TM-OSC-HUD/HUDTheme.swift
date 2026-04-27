import SwiftUI

enum HUDTheme: String, CaseIterable, Identifiable {
    case proOrange, classicBlue, dark, light
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .classicBlue:   return "Classic (Blue)"
        case .proOrange: return "Pro (Orange)"
        case .dark:      return "Dark"
        case .light:     return "Light"
        }
    }
    
    var foreground: Color {
        switch self {
        case .light: return Color(white: 0.01)
        case .dark: return Color(white: 0.9)
        case .classicBlue: return Color(red: 0.84, green: 0.84, blue: 0.87)
        case .proOrange: return Color(red: 0.93, green: 0.74, blue: 0.35)
        }
    }
    
    var background: Color {
        switch self {
        case .light: return Color(white: 0.99)
        case .dark, .proOrange: return Color(white: 0.27)
        case .classicBlue: return Color(red: 0.25, green: 0.35, blue: 0.51)
        }
    }
    var warning: Color {
            switch self {
            case .classicBlue: return .orange
            case .proOrange:   return Color(red: 1.0, green: 0.6, blue: 0.0)
            case .light:       return .orange
            case .dark:        return .orange
            }
        }
        
        var critical: Color {
            switch self {
            case .classicBlue: return .red
            case .proOrange:   return Color(red: 1.0, green: 0.4, blue: 0.3)
            case .light:       return .red
            case .dark:        return .red
            }
        }
}
