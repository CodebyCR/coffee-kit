//
//  CoffeeColor.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 05.07.25.
//

public enum CoffeeColor: String, CaseIterable, Sendable {
    case coffeeBrownLight
    case coffeeBrownDark
    case coffeeAccent

    public func getRGB() -> (red: Double, green: Double, blue: Double) {
        switch self {
        case .coffeeBrownLight:
            // #8B4513
            return (0.545, 0.271, 0.075) // Light coffee brown
           // return (0.8, 0.52, 0.36) // Light coffee brown
        case .coffeeBrownDark:
            // #5A3319
            return (0.353, 0.2, 0.098) // Dark coffee brown
//            return (0.4, 0.26, 0.18) // Dark coffee brown
        case .coffeeAccent:
            // #F5F5DC
            return (0.961, 0.961, 0.863) // Accent color for coffee
//            return (0.9, 0.75, 0.5) // Accent color for coffee
        }
    }
}
