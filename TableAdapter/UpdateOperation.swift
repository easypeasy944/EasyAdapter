//
//  UpdateOperation.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 13.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import Foundation

typealias ReloadCompletionBlock<T: AnyObject> = (_ newData : NSMapTable<NSIndexPath, T>,
                                      _ deletingIndexPaths : [NSIndexPath],
                                     _ insertingIndexPaths : [NSIndexPath],
                                        _ movingIndexPaths : [NSIndexPath: NSIndexPath]) -> Void where T: Data

final class UpdateOperation<T: AnyObject>: Operation where T: Data {
    
    private var data : NSMapTable<NSIndexPath, T>
    private var array: [T]
    private var resultBlock: ReloadCompletionBlock<T>
    private var sortBlock: SortBlock<T>?
    private var updateExisting: Bool
    
    init(data       : NSMapTable<NSIndexPath, T>,
         array      : [T],
         sortBlock  : SortBlock<T>?,
         updateExisting: Bool,
         resultBlock: @escaping ReloadCompletionBlock<T>) {
        
        self.updateExisting = updateExisting
        self.sortBlock      = sortBlock
        self.data           = data
        self.array          = array
        self.resultBlock    = resultBlock
    }
    
    override func main() {
        
        //Log("Main update - \(self.name)")
        
        if self.isCancelled { return }
        
        let newData: NSMapTable<NSIndexPath, T> = NSMapTable<NSIndexPath, T>()
        
        var insertingIndexPaths: [NSIndexPath] = []
        var movingIndexPaths: [NSIndexPath: NSIndexPath] = [:]
        var deletingIndexPaths: [NSIndexPath] = []
        
        var allIndexPaths: [NSIndexPath] = self.data.keyEnumerator().allObjects as! [NSIndexPath]
        
        let newDataSet: NSOrderedSet = NSOrderedSet(array: self.array)
        
        var newArray: [T] = newDataSet.array as! [T]
        
        if self.isCancelled { return }
        
        if let lSortBlock = self.sortBlock {
            newArray.sort(by: lSortBlock)
        }

        if self.isCancelled { return }
        
        for i in 0..<newArray.count {
            
            if self.isCancelled { return }
            
            var index: NSIndexPath?
            
            for key in allIndexPaths {
                guard let object = self.data.object(forKey: key) else { continue }
                if newArray[i].hashValue == object.hashValue {
                    index = key
                    break
                }
            }
            
            let newIndexPath = NSIndexPath(row: i, section: 0)
            if let lIndex = index {
                movingIndexPaths[lIndex] = newIndexPath
            } else {
                let newIndexPath = newIndexPath
                insertingIndexPaths.append(newIndexPath)
            }
            
            if self.updateExisting {
                newData.setObject(newArray[i], forKey: newIndexPath)
            } else {
                let prevObject: T = self.data.object(forKey: newIndexPath)!
                newData.setObject(prevObject, forKey: newIndexPath)
            }
        }
        
        if self.isCancelled { return }
        
        movingIndexPaths.keys.forEach { (indexPath) in
            let index = allIndexPaths.index(of: indexPath)
            if let lIndex = index { allIndexPaths.remove(at: lIndex) }
        }
        
        deletingIndexPaths = allIndexPaths
        
//        Log("Update")
//        Log("Prev data in main \(self.name) - \(self.data.count)")
//        Log("Prev insert in main \(self.name) - \(insertingIndexPaths.count)")
//        Log("Prev delete in main \(self.name) - \(deletingIndexPaths.count)")
//        Log("Prev newData in main \(self.name) - \(newData.count)")

        
        if self.isCancelled { return }
        
        if self.data.count + insertingIndexPaths.count - deletingIndexPaths.count != newData.count {
            
        }
        
        self.resultBlock(newData, deletingIndexPaths, insertingIndexPaths, movingIndexPaths)
        
        //Log("Finish - \(self.name)")
    }
}
