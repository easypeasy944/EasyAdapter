//
//  UpdateOperation.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 13.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import Foundation

typealias ReloadCompletionBlock<T: AnyObject> = (_ newData : NSMapTable<NSIndexPath, T>,
                                      _ deletingIndexPaths : [IndexPath],
                                     _ insertingIndexPaths : [IndexPath],
                                        _ movingIndexPaths : [IndexPath: IndexPath]) -> Void where T: Data

final class UpdateOperation<T: AnyObject>: Operation where T: Data {
    
    private var data : NSMapTable<NSIndexPath, T>
    private var array: [T]
    private var resultBlock: ReloadCompletionBlock<T>
    private var sortBlock: SortBlock<T>?
    private var updateExisting: Bool
    
    init(newData    : NSMapTable<NSIndexPath, T>,
         array      : [T],
         sortBlock  : SortBlock<T>?,
         updateExisting: Bool,
         resultBlock: @escaping ReloadCompletionBlock<T>) {
        
        self.updateExisting = updateExisting
        self.sortBlock   = sortBlock
        self.data        = newData
        self.array       = array
        self.resultBlock = resultBlock
    }
    
    override func main() {
        
        //Log("Main update - \(self.name)")
        
        let newData: NSMapTable<NSIndexPath, T> = NSMapTable<NSIndexPath, T>()
        
        var insertingIndexPaths: [IndexPath] = []
        var movingIndexPaths: [IndexPath: IndexPath] = [:]
        var deletingIndexPaths: [IndexPath] = []
        
        var allIndexPaths: [IndexPath] = self.data.keyEnumerator().allObjects as! [IndexPath]
        
        let newDataSet: NSOrderedSet = NSOrderedSet(array: self.array)
        
        var newArray: [T] = newDataSet.array as! [T]
        
        if let lSortBlock = self.sortBlock {
            newArray.sort(by: lSortBlock)
        }

        if self.isCancelled { return }
        
        for i in 0..<newArray.count {
            
            if self.isCancelled { return }
            
            var index: IndexPath?
            
            for key in allIndexPaths {
                guard let object = self.data.object(forKey: key as NSIndexPath?) else { continue }
                if newArray[i].hashValue == object.hashValue {
                    index = key
                    break
                }
            }
            
            let newIndexPath = IndexPath(row: i, section: 0)
            if let lIndex = index {
                movingIndexPaths[lIndex] = newIndexPath
            } else {
                let newIndexPath = newIndexPath
                insertingIndexPaths.append(newIndexPath)
            }
            
            if self.updateExisting {
                newData.setObject(newArray[i], forKey: newIndexPath as NSIndexPath?)
            } else {
                let prevObject: T = self.data.object(forKey: newIndexPath as NSIndexPath?)!
                newData.setObject(prevObject, forKey: newIndexPath as NSIndexPath?)
            }
        }
        
        if self.isCancelled { return }
        
        movingIndexPaths.keys.forEach { (indexPath) in
            let index = allIndexPaths.index(of: indexPath)
            if let lIndex = index { allIndexPaths.remove(at: lIndex) }
        }
        
        deletingIndexPaths = allIndexPaths
        
        //Log("Prev data in main \(self.name) - \(self.data.count)")
        //Log("Prev insert in main \(self.name) - \(insertingIndexPaths.count)")
        //Log("Prev delete in main \(self.name) - \(deletingIndexPaths.count)")
        //Log("Prev newData in main \(self.name) - \(newData.count)")
        
        if self.data.count + insertingIndexPaths.count - deletingIndexPaths.count != newData.count {
            
        }
        
        if self.isCancelled { return }
        
        self.resultBlock(newData, deletingIndexPaths, insertingIndexPaths, movingIndexPaths)
        
        //Log("Finish - \(self.name)")
    }
}
