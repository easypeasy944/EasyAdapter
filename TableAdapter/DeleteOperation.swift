//
//  DeleteOperation.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 4.декабря.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import UIKit

final class DeleteOperation<T: AnyObject>: Operation where T: Data {

    private var data : NSMapTable<NSIndexPath, T>
    private var array: [T]
    private var resultBlock: ReloadCompletionBlock<T>
    
    init(newData    : NSMapTable<NSIndexPath, T>,
         array      : [T],
         resultBlock: @escaping ReloadCompletionBlock<T>) {
        
        self.data        = newData
        self.array       = array
        self.resultBlock = resultBlock
    }
    
    override func main() {
        
        //Log("Main delete")
        
        if self.isCancelled { return }
        
        let newData: NSMapTable<NSIndexPath, T> = NSMapTable<NSIndexPath, T>()

        var deletingIndexPaths: [NSIndexPath] = []
        
        var indexPath: NSIndexPath = NSIndexPath(row: 0, section: 0)
        
        for key in self.data.keyEnumerator().allObjects as! [NSIndexPath] {
            guard let value = self.data.object(forKey: key as NSIndexPath?) else { continue }
            if self.array.contains(value) {
                deletingIndexPaths.append(key)
            } else {
                newData.setObject(value, forKey: indexPath as NSIndexPath?)
                indexPath = NSIndexPath(row: indexPath.row + 1, section: indexPath.section)
            }
        }
        
        if self.data.count - deletingIndexPaths.count != newData.count {
            
        }
        
//        Log("Delete") 
//        Log("Prev data in main \(self.name) - \(self.data.count)")
//        Log("Prev delete in main \(self.name) - \(deletingIndexPaths.count)")
//        Log("Prev newData in main \(self.name) - \(newData.count)")
        
        self.resultBlock(newData, deletingIndexPaths, [], [:])
        
        //Log("Finish - \(self.name)")
    }
}
