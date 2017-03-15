//
//  Book.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 13.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import Foundation

class Book: Data, CustomDebugStringConvertible {
    
    var id: String
    var name: String
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
    
    var hashValue: Int {
        return self.id.hashValue
    }
    
    static func <(lhs: Book, rhs: Book) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func >(lhs: Book, rhs: Book) -> Bool {
        return lhs.name > rhs.name
    }
    
    static func <=(lhs: Book, rhs: Book) -> Bool {
        return lhs.name <= rhs.name
    }
    
    static func >=(lhs: Book, rhs: Book) -> Bool {
        return lhs.name >= rhs.name
    }
    
    static func ==(lhs: Book, rhs: Book) -> Bool {
        return lhs.name == rhs.name
    }
    
    var debugDescription: String {
        return "Id - \(self.id), Name - \(self.name), Hash - \(self.hashValue)"
    }
}
