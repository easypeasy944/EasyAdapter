//
//  Helpers.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 13.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import Foundation

extension Thread {
    
    static func performOnMainThread(block: @escaping (() -> ())) {
        
        if self.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync(execute: block)
        }
    }
}

extension Dictionary where Value: Data {
    
    mutating func fs_removeValue(object: Dictionary.Value) -> [Dictionary.Key] {
        var affectedKeys: [Key] = []
        for (key, value) in self {
            if value == object { affectedKeys.append(key) }
            else { continue }
        }
        affectedKeys.forEach { (key) in
            self.removeValue(forKey: key)
        }
        return affectedKeys
    }
}

extension Array {
    
    func distinct(includeElement: (_ lhs: Element, _ rhs: Element) -> Bool) -> [Element] {
        var results = [Element]()
        
        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }
}
