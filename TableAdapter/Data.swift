//
//  Data.swift
//  EasyAdapter
//
//  Created by Aynur Galiev on 13.04.17.
//  Copyright © 2017 Aynur Galiev. All rights reserved.
//

import Foundation

public protocol Data: AnyObject, Equatable {
    var uniqueID: String { get }
}
