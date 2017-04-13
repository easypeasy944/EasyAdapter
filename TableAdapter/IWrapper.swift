//
//  IWrapper.swift
//  EasyAdapter
//
//  Created by Aynur Galiev on 13.04.17.
//  Copyright © 2017 Aynur Galiev. All rights reserved.
//

import Foundation

class IWrapper<T: Data>: Equatable {
    
    var value: T? {
        return nil
    }
}

func == <T: Data>(lhs: IWrapper<T>, rhs: IWrapper<T>) -> Bool {
    return lhs.value == rhs.value
}
