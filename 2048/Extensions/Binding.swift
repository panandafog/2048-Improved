//
//  Binding.swift
//  2048
//
//  Created by Andrey on 08.05.2023.
//

import SwiftUI

extension Binding where Value == Int {
    public func string() -> Binding<String> {
        return Binding<String>(
            get: { String(self.wrappedValue) },
            set: { self.wrappedValue = Int($0) ?? 0 }
        )
    }
}
