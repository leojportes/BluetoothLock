//
//  Array+Ext.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 09/09/22.
//

import Foundation

public extension Array {
    static func += (lhs: inout Self, rhs: Self.Element) {
        lhs.append(rhs)
    }

    func doesNotContain(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        try !contains(where: predicate)
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}

public extension Array where Element: Equatable {

    func doesNotContain(_ element: Element) -> Bool {
        !contains(element)
    }

    func contains(_ sequence: [Element]) -> Bool {
        sequence.allSatisfy { contains($0) }
    }
}
