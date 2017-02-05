//
//  TableAdapter.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 6.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import Foundation
import UIKit

typealias MemoryOption = NSPointerFunctions.Options
typealias SortBlock<T> = ((_ lhs: T, _ rhs: T) -> Bool)

var printQueue: DispatchQueue = DispatchQueue(label: "com.flatstack.Print")

func Log(_ message: String) {
    NSLog(message)
}

final class TableAdapter<T: AnyObject>: NSObject where T: Data {

    private weak var tableView: UITableView?
    private var data: NSMapTable<NSIndexPath, T>
    private var sortBlock: SortBlock<T>?
    
    //MARK: - Animations
    var deleteAnimation: UITableViewRowAnimation = .right
    var insertAnimation: UITableViewRowAnimation = .left
    var reloadAnimation: UITableViewRowAnimation = .automatic
    
    //MARK: - Queues
    private var lockQueue: DispatchQueue = DispatchQueue(label: "com.flatstack.LockData")
    
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue(label: "com.flatstack.ReloadOperations")
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var lock: NSLock = NSLock()
    
    init(tableView: UITableView, referenced options: MemoryOption) {
        self.tableView = tableView
        self.data = NSMapTable(keyOptions: MemoryOption.strongMemory, valueOptions: options)
        super.init()
        //self.operationQueue.addObserver(self, forKeyPath: "operationCount", options: [.new], context: nil)
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "operationCount" {
//            print("OPERATIONS COUNT - \(self.operationQueue.operationCount)")
//        } else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
//    }
    
//    deinit {
//        self.operationQueue.removeObserver(self, forKeyPath: "operationCount")
//    }
    
    var dataCount: Int {
        return self.tableData.count
    }
    
    subscript(indexPath: IndexPath) -> T? {
        get {
            let value: T? = self.tableData.object(forKey: indexPath as NSIndexPath?)
            //Log("Get value - \(self.tableData.count)")
            return value
        }
        set(newValue) {
            self.tableData.setObject(newValue, forKey: indexPath as NSIndexPath?)
            //Log("Set value - \(self.tableData.count)")
        }
    }
    
    private(set) var tableData: NSMapTable<NSIndexPath, T> {
        get {
            var currentData: NSMapTable<NSIndexPath, T>! = nil
            self.lockQueue.sync {
                currentData = self.data
            }
            //Log("Get - \(currentData.count)")
            return currentData
        }
        set(newValue) {
            self.lockQueue.sync {
                self.data = newValue
            }
            //Log("Set - \(self.data.count)")
        }
    }
    
    
    
    func set(sortBlock block: SortBlock<T>) {
        
    }
    
    func set(data array: [T], update: Bool = true) {
        
            let name = UUID().uuidString
            Log("Start new set operation - \(name)")
            
            let operation = UpdateOperation(newData : self.tableData,
                                              array : array,
                                          sortBlock : self.sortBlock,
                                     updateExisting : update,
                                        resultBlock : self.tableOperationBlock)
            operation.name = name
            self.operationQueue.addOperation(operation)
        
    }
    
    func insert(array: [T], updateExisting: Bool = true) {
        let name = UUID().uuidString
        Log("Start new insert operation - \(name)")
        
        let operation = InsertOperation(newData : self.tableData,
                                          array : array,
                                      sortBlock : self.sortBlock,
                                 updateExisting : updateExisting,
                                    resultBlock : self.tableOperationBlock)
        operation.name = name
        self.operationQueue.addOperation(operation)
    }
    
    func insert(object: T, updateExisting: Bool = true) {
        self.insert(array: [object], updateExisting: updateExisting)
    }
    
    func delete(array: [T]) {
        
        
        let name = UUID().uuidString
        Log("Start new delete operation - \(name)")
        
        let operation = DeleteOperation(newData : self.tableData,
                                          array : array,
                                    resultBlock : self.tableOperationBlock)
        operation.name = name
        self.operationQueue.addOperation(operation)
        
    }
    
    func delete(object: T) {
        self.delete(array: [object])
    }
    
    func cancellAllReloadOperations() {
        self.operationQueue.cancelAllOperations()
    }
    
    private lazy var tableOperationBlock: ReloadCompletionBlock<T> = {
        
        return { [weak self] (newData: NSMapTable<NSIndexPath, T>, deletingRows: [IndexPath], insertingRows: [IndexPath], movingRows: [IndexPath: IndexPath]) in
            
            guard let sself = self, let lTableView = sself.tableView else { return }
            
            let prevCount = sself.tableData.count
            
            Log("---------")
            Log("Prev - \(sself.tableData.count)")
            Log("New - \(newData.count)")
            
            var notModifiedIndexPaths: [IndexPath: IndexPath] = [:]
            var modifiedIndexPaths: [IndexPath: IndexPath] = [:]
            
            for movingRow in movingRows {
                guard let prevObject = sself.tableData.object(forKey: movingRow.key as NSIndexPath?) else { continue }
                guard let newObject  = newData.object(forKey: movingRow.value as NSIndexPath?) else { continue }
                if prevObject != newObject {
                    modifiedIndexPaths[movingRow.key] = movingRow.value
                } else {
                    notModifiedIndexPaths[movingRow.key] = movingRow.value
                }
            }
            
            sself.tableData.removeAllObjects()
            for key in newData.keyEnumerator().allObjects as! [IndexPath] {
                let object = newData.object(forKey: key as NSIndexPath?)
                sself.tableData.setObject(object, forKey: key as NSIndexPath?)
            }

            Thread.performOnMainThread {

                if prevCount + insertingRows.count - deletingRows.count != newData.count {
                    Log("Crash")
                }
                
                lTableView.update {
                    for (key, value) in movingRows {
                        lTableView.moveRow(at: key, to: value)
                    }
                    lTableView.deleteRows(at: deletingRows, with: sself.deleteAnimation)
                    lTableView.insertRows(at: insertingRows, with: sself.insertAnimation)
                }
                
                lTableView.update {
                    for row in lTableView.indexPathsForVisibleRows ?? [] {
                        let cell = lTableView.cellForRow(at: row) as? BookCell
                        cell?.contentView.fadeTransition(duration: 0.2)
                        cell?.bookLabel.text = (sself.tableData.object(forKey: row as NSIndexPath?) as? Book)?.name
                    }
                }

            }
        }
    }()
}


extension UIView {
    
    func fadeTransition(duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        self.layer.add(animation, forKey: kCATransitionFade)
    }
}

extension UITableView {
    
    func update(updateBlock: (() -> ())) {
        self.beginUpdates()
        updateBlock()
        self.endUpdates()
    }
}
