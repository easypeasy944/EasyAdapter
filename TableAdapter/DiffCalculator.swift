//
//  DiffCalculator.swift
//  EasyAdapter
//
//  Created by Aynur Galiev on 13.04.17.
//  Copyright © 2017 Aynur Galiev. All rights reserved.
//

import Foundation

protocol IDiffCalculator {
    associatedtype ValueType: Data
    func performCalculate(source1: DataSource<ValueType>,
                          source2: DataSource<ValueType>,
           shouldReplaceIndexPath: Bool,
                   updateIfExists: Bool) -> DiffResult
}

open class DiffCalculator<T: Data>: IDiffCalculator {
    
    typealias ValueType = T
    
    //NOTE: - Need to ensure that sources doesn't contain duplicates
    func performCalculate(source1: DataSource<T>,
                          source2: DataSource<T>,
           shouldReplaceIndexPath: Bool,
                   updateIfExists: Bool) -> DiffResult {
        
        var initialKeys: [IndexPath] = source1.fs_keys
        var initialValues: [IWrapper<T>] = source1.fs_values
        
        //MARK: - Rows
        var deleteRows       : [IndexPath] = []
        var insertRows       : [IndexPath] = []
        var modificationRows : [IndexPath] = []
        var moveRows         : [IndexPath : IndexPath] = [:]
        
        //MARK: - Sections
        var deleteSections       : [Int] = []
        var insertSections       : [Int] = []
        var modificationSections : [Int] = []
        var moveSections         : [Int] = []
        
        var resultedDataSource: DataSource<T> = DataSource<T>()
        
        for (key2, value2) in source2 {

            var containedKeys: [IndexPath] = []
            
            //MARK: - Checking if item of source2 already in source1
            for (key1, value1) in source1 {
                guard let lhs = value1.value, let rhs = value2.value else { continue }
                guard lhs == rhs else { continue }
                containedKeys.append(key1)
            }
            
            assert(containedKeys.count < 2, "Duplicates found")
            
            //MARK: - if value already was in first source ..
            if containedKeys.count == 1 {
                
                let key: IndexPath = containedKeys.first!
                let desiredIndexPath: IndexPath!
                let desiredValue: IWrapper<T>!
                
                //If items' uniqueID is equal, we need decide which row item should be on. If `shouldReplaceIndexPath` defined - 
                //we choose new position and performs move animation, else - do nothing
                if shouldReplaceIndexPath {
                    desiredIndexPath = key2
                    moveRows[key] = key2
                } else {
                    desiredIndexPath = key
                }
                
                //If items' uniqueID is equal, but items are not equal we must decide old or new version of object should be 
                //included in result. If true - reload row, else - do nothing.
                if updateIfExists {
                    desiredValue = value2
                    modificationRows.append(key)
                } else {
                    desiredValue = source1[key]
                }
                
                resultedDataSource[desiredIndexPath] = desiredValue
            }
            //MARK: - ... else make insert
            else {
                
                
            }
        }
        
        let rows = DiffResult.Rows(deletions: [], insertions: [], modifications: [], moves: [])
        let sections = DiffResult.Sections(deletions: [], insertions: [], modifications: [], moves: [])
        
        return DiffResult(rows: rows, sections: sections)
    }
}
