//
//  UpdateOperation.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 13.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import Foundation

//final class UpdateOperation<T: AnyObject>: Operation where T: Data {
//    
//    private var data : NSMapTable<NSIndexPath, T>
//    private var array: [T]
//    private var resultBlock: ReloadCompletionBlock<T>
//    private var sortBlock: SortBlock<T>?
//    private var updateExisting: Bool
//    
//    init(data       : NSMapTable<NSIndexPath, T>,
//         array      : [T],
//         sortBlock  : SortBlock<T>?,
//         updateExisting: Bool,
//         resultBlock: @escaping ReloadCompletionBlock<T>) {
//        
//        self.updateExisting = updateExisting
//        self.sortBlock      = sortBlock
//        self.data           = data
//        self.array          = array
//        self.resultBlock    = resultBlock
//    }
//    
//    override func main() {
//        
//        if self.isCancelled { return }
//        
//        let newData: NSMapTable<NSIndexPath, T> = NSMapTable<NSIndexPath, T>()
//        
//        var insertingIndexPaths: [NSIndexPath] = []
//        var movingIndexPaths   : [NSIndexPath: NSIndexPath] = [:]
//        var deletingIndexPaths : [NSIndexPath] = []
//        
//        var allIndexPaths: [NSIndexPath] = self.data.keyEnumerator().allObjects as! [NSIndexPath]
//        
//        let newDataSet: NSOrderedSet = NSOrderedSet(array: self.array)
//        
//        var newArray: [T] = newDataSet.array as! [T]
//        
//        if self.isCancelled { return }
//        
//        if let lSortBlock = self.sortBlock {
//            newArray.sort(by: lSortBlock)
//        }
//
//        if self.isCancelled { return }
//        
//        for i in 0..<newArray.count {
//            
//            if self.isCancelled { return }
//            
//            var index: NSIndexPath?
//            
//            for key in allIndexPaths {
//                guard let object = self.data.object(forKey: key) else { continue }
//                if newArray[i].hashValue == object.hashValue {
//                    index = key
//                    break
//                }
//            }
//            
//            let newIndexPath = NSIndexPath(row: i, section: 0)
//            if let lIndex = index {
//                movingIndexPaths[lIndex] = newIndexPath
//            } else {
//                let newIndexPath = newIndexPath
//                insertingIndexPaths.append(newIndexPath)
//            }
//            
//            if self.updateExisting {
//                newData.setObject(newArray[i], forKey: newIndexPath)
//            } else {
//                if let prevObject = self.data.object(forKey: index) {
//                    newData.setObject(prevObject, forKey: newIndexPath)
//                } else {
//                    newData.setObject(newArray[i], forKey: newIndexPath)
//                }
//            }
//        }
//        
//        if self.isCancelled { return }
//        
//        movingIndexPaths.keys.forEach { (indexPath) in
//            let index = allIndexPaths.index(of: indexPath)
//            if let lIndex = index { allIndexPaths.remove(at: lIndex) }
//        }
//        
//        deletingIndexPaths = allIndexPaths
//        
//        if self.isCancelled { return }
//        
//        self.resultBlock(newData, deletingIndexPaths, insertingIndexPaths, movingIndexPaths)
//
//    }
//}
