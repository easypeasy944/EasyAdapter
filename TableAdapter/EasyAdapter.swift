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

typealias ReloadCompletionBlock<T: AnyObject> = (_ newData : NSMapTable<NSIndexPath, T>,
                                      _ deletingIndexPaths : [NSIndexPath],
                                     _ insertingIndexPaths : [NSIndexPath],
                                        _ movingIndexPaths : [NSIndexPath: NSIndexPath]) -> Void where T: Data

protocol IReloadable: class {
    func tableView<T>(_ tableView: UITableView, configureCell cell: UITableViewCell, indexPath: NSIndexPath, data: T)
}

protocol Data: Comparable, Hashable {}

final class EasyAdapter<T: AnyObject>: NSObject where T: Data {

    //MARK: - Private variables
    private weak var tableView : UITableView?
    private var data           : NSMapTable<NSIndexPath, T>
    private var sortBlock      : SortBlock<T>?
    private weak var delegate  : IReloadable?
    
    //MARK: - Animation settings
    var deleteAnimation: UITableViewRowAnimation = .right
    var insertAnimation: UITableViewRowAnimation = .left
    var reloadAnimation: UITableViewRowAnimation = .automatic
    
    //MARK: - Sync queues
    private var lockQueue: DispatchQueue = DispatchQueue(label: "com.flatstack.LockData")
    
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue(label: "com.flatstack.ReloadOperations")
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }()

    init(tableView: UITableView, referenced options: MemoryOption, delegate: IReloadable) {
        self.tableView = tableView
        self.delegate = delegate
        self.data = NSMapTable(keyOptions: MemoryOption.strongMemory, valueOptions: options)
        super.init()
    }
    
    var dataCount: Int {
        return self.tableData.count
    }
    
    subscript(indexPath: NSIndexPath) -> T? {
        get {
            return self.tableData.object(forKey: indexPath as NSIndexPath?)
        }
        set(newValue) {
            self.tableData.setObject(newValue, forKey: indexPath as NSIndexPath?)
        }
    }
    
    private(set) var tableData: NSMapTable<NSIndexPath, T> {
        get {
            var currentData: NSMapTable<NSIndexPath, T>! = nil
            self.lockQueue.sync {
                currentData = self.data
            }
            return currentData
        }
        set(newValue) {
            self.lockQueue.sync {
                self.data.removeAllObjects()
                let allIndexPaths: [NSIndexPath] = newValue.keyEnumerator().allObjects as! [NSIndexPath]
                for indexPath in allIndexPaths {
                    let value = newValue.object(forKey: indexPath)
                    self.data.setObject(value, forKey: indexPath)
                }
            }
        }
    }
    
    func set(sortBlock block: @escaping SortBlock<T>) {
        self.sortBlock = block
        let operation = InsertOperation(newData : self.tableData,
                                        array   : [],
                                      sortBlock : self.sortBlock,
                                 updateExisting : false,
                                    resultBlock : self.tableOperationBlock)
        self.operationQueue.addOperation(operation)
    }
    
    func set(data array: [T], update: Bool = true) {

        let operation = UpdateOperation(data    : self.tableData,
                                          array : array,
                                      sortBlock : self.sortBlock,
                                 updateExisting : update,
                                    resultBlock : self.tableOperationBlock)
        self.operationQueue.addOperation(operation)
    }
    
    func insert(array: [T], updateExisting: Bool = true) {

        let operation = InsertOperation(newData : self.tableData,
                                          array : array,
                                      sortBlock : self.sortBlock,
                                 updateExisting : updateExisting,
                                    resultBlock : self.tableOperationBlock)
        self.operationQueue.addOperation(operation)
    }
    
    func insert(object: T, updateExisting: Bool = true) {
        self.insert(array: [object], updateExisting: updateExisting)
    }
    
    func delete(array: [T]) {

        let operation = DeleteOperation(newData : self.tableData,
                                          array : array,
                                    resultBlock : self.tableOperationBlock)
        self.operationQueue.addOperation(operation)
        
    }
    
    func delete(object: T) {
        self.delete(array: [object])
    }
    
    func reload() {
        self.operationQueue.addOperation { [weak self] in
            Thread.performOnMainThread {
                self?.tableView?.reloadData()
            }
        }
    }
    
    func cancellAllReloadOperations() {
        self.operationQueue.cancelAllOperations()
    }
    
    private lazy var tableOperationBlock: ReloadCompletionBlock<T> = {
        
        return { [weak self] (newData: NSMapTable<NSIndexPath, T>, deletingRows: [NSIndexPath], insertingRows: [NSIndexPath], movingRows: [NSIndexPath: NSIndexPath]) in
            
            guard let sself = self, let tableView = sself.tableView else { return }
            
            let previousDataCount: Int = sself.tableData.count
            sself.tableData = newData

            print(insertingRows.map { $0.row })
            
            Thread.performOnMainThread {

                guard previousDataCount + insertingRows.count - deletingRows.count == newData.count else {
                    print("WARNING: Data inconsistency. Update skipped")
                    tableView.reloadData()
                    return
                }
                
                tableView.update {
                    for (key, value) in movingRows {
                        tableView.moveRow(at: key as IndexPath, to: value as IndexPath)
                    }
                    tableView.deleteRows(at: deletingRows as [IndexPath], with: sself.deleteAnimation)
                    tableView.insertRows(at: insertingRows as [IndexPath], with: sself.insertAnimation)
                }
                
                tableView.update {
                    for row in tableView.indexPathsForVisibleRows ?? [] {
                        guard let cell = tableView.cellForRow(at: row) else { continue }
                        sself.delegate?.tableView(tableView, configureCell: cell, indexPath: row as NSIndexPath, data: sself[row as NSIndexPath])
                    }
                }
            }
        }
    }()
}


extension UIView {
    
    func fadeTransition(duration: CFTimeInterval) {
        let animation: CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
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
