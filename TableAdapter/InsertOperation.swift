//
//  InsertOperation.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 4.декабря.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import UIKit

//final class InsertOperation<T: AnyObject>: Operation where T: Data  {
//
//    private var data : NSMapTable<NSIndexPath, T>
//    private var array: [T]
//    private var resultBlock: ReloadCompletionBlock<T>
//    private var sortBlock: SortBlock<T>?
//    private var updateExisting: Bool
//    
//    init(newData        : NSMapTable<NSIndexPath, T>,
//         array          : [T],
//         sortBlock      : SortBlock<T>?,
//         updateExisting : Bool,
//         resultBlock    : @escaping ReloadCompletionBlock<T>) {
//        
//        self.updateExisting = updateExisting
//        self.sortBlock   = sortBlock
//        self.data        = newData
//        self.array       = array
//        self.resultBlock = resultBlock
//    }
//    
//    override func main() {
//        
//        if self.isCancelled { return }
//        
//        let newData: NSMapTable<NSIndexPath, T> = NSMapTable<NSIndexPath, T>()
//        
//        var insertingIndexPaths: [NSIndexPath] = []
//        var movingIndexPaths: [NSIndexPath: NSIndexPath] = [:]
//        
//        var allIndexPaths: [NSIndexPath] = self.data.keyEnumerator().allObjects as! [NSIndexPath]
//        allIndexPaths.sort { $0.row < $1.row }
//        
//        var allValues: [T] = []
//        for indexPath in allIndexPaths {
//            let value = self.data.object(forKey: indexPath)
//            allValues.append(value!)
//        }
//        
//        if self.isCancelled { return }
//        
//        var resultArray: [T] = allValues
//        let newDataArray = self.array.distinct(includeElement: { $0.hashValue == $1.hashValue })
//        
//        for value in newDataArray {
//            let index = resultArray.index(where: { $0.hashValue == value.hashValue })
//            if let lIndex = index {
//                if self.updateExisting {
//                    resultArray.remove(at: lIndex)
//                    resultArray.append(value)
//                }
//            } else {
//                resultArray.append(value)
//            }
//        }
//        
//        if let lSortBlock = self.sortBlock {
//            resultArray.sort(by: lSortBlock)
//        }
//        
//        if self.isCancelled { return }
//        
//        for i in 0..<resultArray.count {
//            
//            let newIndexPath: NSIndexPath = NSIndexPath(row: i, section: 0)
//            newData.setObject(resultArray[i], forKey: newIndexPath)
//            
//            let index = allValues.index(where: { $0.hashValue == resultArray[i].hashValue })
//            
//            if let lIndex = index {
//                let prevIndexPath: NSIndexPath = NSIndexPath(row: lIndex, section: 0)
//                movingIndexPaths[prevIndexPath] = newIndexPath
//            } else {
//                insertingIndexPaths.append(newIndexPath)
//            }
//        }
//
//        if self.isCancelled { return }
//        
//        self.resultBlock(newData, [], insertingIndexPaths, movingIndexPaths)
//    }
//
//}
