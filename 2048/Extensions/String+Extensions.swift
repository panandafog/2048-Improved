//
//  String+Extensions.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: self)
    }
}
