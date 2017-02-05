//
//  InsertOperation.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 4.декабря.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import UIKit

final class InsertOperation<T: AnyObject>: Operation where T: Data  {

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
        
        //Log("Main insert - \(self.name)")
        
        let newData: NSMapTable<NSIndexPath, T> = NSMapTable<NSIndexPath, T>()
        
        var insertingIndexPaths: [IndexPath] = []
        var movingIndexPaths: [IndexPath: IndexPath] = [:]
        
        var allIndexPaths: [IndexPath] = self.data.keyEnumerator().allObjects as! [IndexPath]
        let allValues: [T] = self.data.objectEnumerator()!.allObjects as! [T]
        
        allIndexPaths.sort()
        
        var prevValues: [T] = []
        
        for indexPath in allIndexPaths {
            guard let object = self.data.object(forKey: indexPath as NSIndexPath?) else { continue }
            prevValues.append(object)
        }
        
        let arrayHashes: [Int] = self.array.map { $0.hashValue }
        prevValues = prevValues.filter { !arrayHashes.contains($0.hashValue) }
        prevValues.append(contentsOf: self.array)
        
        if let lSortBlock = self.sortBlock {
            prevValues.sort(by: lSortBlock)
        }
        
        for i in 0..<prevValues.count {
            
            let newIndexPath: IndexPath = IndexPath(row: i, section: 0)
            newData.setObject(prevValues[i], forKey: newIndexPath as NSIndexPath?)
            
            if let _ = allValues.index(of: prevValues[i]) {
            
                var indexPath: IndexPath? = nil
                
                for key in self.data.keyEnumerator().allObjects as! [IndexPath] {
                    guard let object = self.data.object(forKey: key as NSIndexPath?) else { continue }
                    if object == prevValues[i] {
                        indexPath = key
                        break
                    }
                }
                
                movingIndexPaths[indexPath!] = newIndexPath
            } else {
                insertingIndexPaths.append(newIndexPath)
            }
        }
        
        //Log("Prev data in main \(self.name) - \(self.data.count)")
        //Log("Prev insert in main \(self.name) - \(insertingIndexPaths.count)")
        //Log("Prev newData in main \(self.name) - \(newData.count)")
        
        if self.data.count + insertingIndexPaths.count != newData.count {
            
        }
        
        self.resultBlock(newData, [], insertingIndexPaths, movingIndexPaths)
        
        //Log("Finish - \(self.name)")
    }

}
