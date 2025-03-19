//
//  PaymentOption.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 04.12.24.
//

public enum PaymentOption: String, CaseIterable, Sendable, Codable {
    case applePay = "ApplePay"
    case cash = "Cash"

    public static func get(by name: String) -> Self? {
        allCases.first { $0.rawValue == name }
    }
}
