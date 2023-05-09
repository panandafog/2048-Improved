//
//  Color+Extensions.swift
//  2048
//
//  Created by Andrey on 08.05.2023.
//

import SwiftUI

extension Color {
    
    static let gameForeground = Color("GameForeground")
    static let fieldForeground = Color("FieldForeground")
    static let buttonBackground = Color("ButtonBackground")
    
    static let labelLight = Color("LabelLight")
    static let labelLight2 = Color("LabelLight2")
    static let labelDark = Color("LabelDark")
    
    static func cellForeground(_ value: Int?) -> Color {
        if let value = value {
            return Color("Cell\(value)")
        } else {
            return Color("CellEmpty")
        }
    }
    
    static func cellLabel(_ value: Int) -> Color {
        value <= 4 ? Color.labelDark : Color.labelLight
    }
}
