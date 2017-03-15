//
//  TestHelpers.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 5.декабря.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import Foundation
@testable import EasyAdapter

func isArraysEqual(first: [Book], second: [Book]) -> Bool {
    guard first.count == second.count else { return false }
    for i in 0..<first.count {
        guard first[i] == second[i] else { return false }
    }
    return true
}
