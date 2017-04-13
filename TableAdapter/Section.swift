//
//  Section.swift
//  EasyAdapter
//
//  Created by Aynur Galiev on 13.04.17.
//  Copyright © 2017 Aynur Galiev. All rights reserved.
//

import Foundation

typealias Sorting<T: Data> = ((_ lhs: T, _ rhs: T) -> Bool)

protocol ISection: class {
    associatedtype T: Data
    var items: [T] { get }
    var sorting: Sorting<T>? { get }
}

class Section: ISection {
    
    typealias T = SomeData
    
    var sorting: ((SomeData, SomeData) -> Bool)? = nil
    var items: [SomeData] = []
}

class SomeData: Data {

    var hashValue: Int {
        return 3948
    }
    
    var uniqueID: String {
        return ""
    }
    
    var name: String = ""
}



func ==(lhs: SomeData, rhs: SomeData) -> Bool {
    return lhs.name == rhs.name
}
