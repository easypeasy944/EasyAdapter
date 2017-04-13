//
//  StrongWrapper.swift
//  EasyAdapter
//
//  Created by Aynur Galiev on 13.04.17.
//  Copyright © 2017 Aynur Galiev. All rights reserved.
//

import Foundation

final class StrongWrapper<T: Data>: IWrapper<T> {

    private var _value: T?
    
    override var value: T? {
        return _value
    }
    
    init(value: T?) {
        _value = value
    }
}
