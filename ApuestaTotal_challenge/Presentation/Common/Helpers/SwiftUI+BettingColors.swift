//
//  SwiftUI+BettingColors.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 19/03/26.
//

import SwiftUI

enum BettingColors {
    // Principal colors
    static let primary = Color(hex: "#1A237E")
    static let secondary = Color(hex: "#283593")
    static let accent = Color(hex: "#3949AB")
    
    // State
    static let win = Color(hex: "#2E7D32")
    static let loss = Color(hex: "#C62828")
    static let pending = Color(hex: "#F57C00")
    
    // Highlight
    static let oddHighlight = Color(hex: "#FF6F00")
    static let selection = Color(hex: "#5C6BC0")
    
    // Background
    static let cardBackground = Color(hex: "#1E1E1E")
    static let surfaceBackground = Color(hex: "#121212")
    
    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#B0BEC5")
    static let textMuted = Color(hex: "#78909C")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
