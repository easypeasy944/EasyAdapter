//
//  TableAdapterTests.swift
//  TableAdapterTests
//
//  Created by Aynur Galiev on 6.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import XCTest
@testable import EasyAdapter

class EasyAdapterTests: XCTestCase {
    
    private var viewController: TableViewController!
    private var initialState: NSMapTable<NSIndexPath, Book> = NSMapTable<NSIndexPath, Book>()
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue(label: "com.flatstack.TestOperations")
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .utility
        return queue
    }()
    
    private let sortBlock: SortBlock<Book> = { (left: Book, right: Book) -> Bool in
        return left.id < right.id
    }
    
    //Books
    var book1: Book = Book(id: "1", name: "1 Book")
    var book2: Book = Book(id: "2", name: "2 Book")
    var book3: Book = Book(id: "3", name: "3 Book")
    var book4: Book = Book(id: "4", name: "4 Book")
    var book5: Book = Book(id: "5", name: "5 Book")
    
    //New books
    var newBook1: Book = Book(id: "1", name: "New 1 Book")
    var newBook2: Book = Book(id: "2", name: "New 2 Book")
    var newBook3: Book = Book(id: "3", name: "New 3 Book")
    var newBook4: Book = Book(id: "4", name: "New 4 Book")
    var newBook5: Book = Book(id: "5", name: "New 5 Book")
    var newBook6: Book = Book(id: "6", name: "New 6 Book")
    var newBook7: Book = Book(id: "7", name: "New 7 Book")
    var newBook8: Book = Book(id: "8", name: "New 8 Book")
    var newBook9: Book = Book(id: "9", name: "New 9 Book")
    var newBook10: Book = Book(id: "10", name: "New 10 Book")
    
    
    lazy var firstPartBooks: [Book] = {
        var books: [Book] = []
        books.append(Book(id: "1", name: "1 Book"))
        books.append(Book(id: "2", name: "2 Book"))
        books.append(Book(id: "3", name: "3 Book"))
        books.append(Book(id: "4", name: "4 Book"))
        books.append(Book(id: "5", name: "5 Book"))
        return books
    }()
    
    lazy var secondPartBooks: [Book] = {
        var books: [Book] = []
        books.append(Book(id: "1", name: "New 1 Book"))
        books.append(Book(id: "2", name: "New 2 Book"))
        books.append(Book(id: "3", name: "New 3 Book"))
        books.append(Book(id: "4", name: "New 4 Book"))
        books.append(Book(id: "5", name: "New 5 Book"))
        books.append(Book(id: "6", name: "New 6 Book"))
        books.append(Book(id: "7", name: "New 7 Book"))
        books.append(Book(id: "8", name: "New 8 Book"))
        books.append(Book(id: "9", name: "New 9 Book"))
        books.append(Book(id: "10", name: "New 10 Book"))
        return books
    }()
    
    private lazy var initialBooks: [Book] = {
       return [self.book1, self.book2, self.book3]
    }()
    
    override func setUp() {
        super.setUp()
        self.viewController = TableViewController()
        UIApplication.shared.keyWindow?.rootViewController = self.viewController

        self.initialState = NSMapTable<NSIndexPath, Book>()
        
        let semaphore = DispatchSemaphore(value: 0)
        let operation = UpdateOperation<Book>(data: self.initialState, array: self.initialBooks, sortBlock: nil, updateExisting: true) { (data, _, _, _) in
            self.initialState = data
            semaphore.signal()
        }
        self.operationQueue.addOperation(operation)
        semaphore.wait()
    }
    
    override func tearDown() {
        self.viewController = nil
        UIApplication.shared.keyWindow?.rootViewController = nil
        super.tearDown()
    }

    func testCase0() {
        
        let books = [book1, book2, book3]
        
        var initialState = NSMapTable<NSIndexPath, Book>()
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = UpdateOperation<Book>(data: initialState, array: books, sortBlock: nil, updateExisting: true) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == books.count)
            XCTAssertTrue(deletings.count == 0)
            XCTAssertTrue(insertings.count == books.count)
            XCTAssertTrue(movings.count == 0)
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            initialState = data
            XCTAssertTrue(isArraysEqual(first: resultBooks, second: books), "Arrays not equal")
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }
    
    //*****************************************************************************************
    //************************************UPDATE TESTS*****************************************
    //*****************************************************************************************
    
    //MARK: - [Update = true, sort = nil]
    func testCase1() {
        
        let newBooks = [book4, newBook1, book5]
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = UpdateOperation<Book>(data: self.initialState, array: newBooks, sortBlock: nil, updateExisting: true) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == self.initialBooks.count)
            XCTAssertTrue(deletings.count == 2)
            XCTAssertTrue(insertings.count == 2)
            XCTAssertTrue(movings.count == 1)
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = [self.book4, self.newBook1, self.book5]

            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }
    
    //MARK: - [Update = false, sort = nil]
    func testCase2() {
        
        let newBooks = [book4, newBook1, book5]
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = UpdateOperation<Book>(data: initialState, array: newBooks, sortBlock: nil, updateExisting: false) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == self.initialBooks.count)
            XCTAssertTrue(deletings.count == 2)
            XCTAssertTrue(insertings.count == 2)
            XCTAssertTrue(movings.count == 1)
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = [self.book4, self.book1, self.book5]
            
            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }
    
    //MARK: - [Update = true, sort = id]
    func testCase3() {
        
        let newBooks = [book4, newBook1, book5]
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = UpdateOperation<Book>(data: initialState, array: newBooks, sortBlock: sortBlock, updateExisting: true) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == self.initialBooks.count)
            XCTAssertTrue(deletings.count == 2)
            XCTAssertTrue(insertings.count == 2)
            XCTAssertTrue(movings.count == 1)
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = [self.newBook1, self.book4, self.book5]
            
            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }
    
    //MARK: - [Update = false, sort = id]
    func testCase4() {
        
        let newBooks = [book4, newBook1, book5]
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = UpdateOperation<Book>(data: initialState, array: newBooks, sortBlock: sortBlock, updateExisting: false) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == self.initialBooks.count)
            XCTAssertTrue(deletings.count == 2)
            XCTAssertTrue(insertings.count == 2)
            XCTAssertTrue(movings.count == 1)
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = [self.book1, self.book4, self.book5]

            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }

    //*****************************************************************************************
    //************************************INSERT TESTS*****************************************
    //*****************************************************************************************
    
    //MARK: - [Update = false, sort = nil]
    func testCase5() {
        
        let newBooks: [Book] = [book4, newBook1, book5]
        
        let distinctCount = (self.initialBooks + newBooks).distinct(includeElement: { $0.hashValue == $1.hashValue }).count
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = InsertOperation<Book>(newData: initialState, array: newBooks, sortBlock: nil, updateExisting: false) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == distinctCount)
            XCTAssertTrue(deletings.count == 0)
            XCTAssertTrue(insertings.count == (distinctCount - self.initialBooks.count))
            XCTAssertTrue(movings.count == (distinctCount - insertings.count))
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = [self.book1, self.book2, self.book3, self.book4, self.book5]
            
            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }
    
    //MARK: - [Update = true, sort = nil]
    func testCase6() {

        let newBooks: [Book] = [book4, newBook1, book5]
        
        let distinctCount = (self.initialBooks + newBooks).distinct(includeElement: { $0.hashValue == $1.hashValue }).count
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = InsertOperation<Book>(newData: initialState, array: newBooks, sortBlock: nil, updateExisting: true) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == distinctCount)
            XCTAssertTrue(deletings.count == 0)
            XCTAssertTrue(insertings.count == (distinctCount - self.initialBooks.count))
            XCTAssertTrue(movings.count == (distinctCount - insertings.count))
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = [self.book2, self.book3, self.book4, self.newBook1, self.book5]
            
            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }

    //MARK: - [Update = false, sort = id]
    func testCase7() {

        let newBooks: [Book] = [book4, newBook1, book5]
        
        let distinctCount = (self.initialBooks + newBooks).distinct(includeElement: { $0.hashValue == $1.hashValue }).count
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = InsertOperation<Book>(newData: initialState, array: newBooks, sortBlock: sortBlock, updateExisting: false) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == distinctCount)
            XCTAssertTrue(deletings.count == 0)
            XCTAssertTrue(insertings.count == (distinctCount - self.initialBooks.count))
            XCTAssertTrue(movings.count == (distinctCount - insertings.count))
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = [self.book1, self.book2, self.book3, self.book4,  self.book5]
            
            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }

    //MARK: - [Update = true, sort = id]
    func testCase8() {
        
        let newBooks: [Book] = [book4, newBook1, book5]
        
        let distinctCount = (self.initialBooks + newBooks).distinct(includeElement: { $0.hashValue == $1.hashValue }).count
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = InsertOperation<Book>(newData: initialState, array: newBooks, sortBlock: sortBlock, updateExisting: true) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == distinctCount)
            XCTAssertTrue(deletings.count == 0)
            XCTAssertTrue(insertings.count == (distinctCount - self.initialBooks.count))
            XCTAssertTrue(movings.count == (distinctCount - insertings.count))
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = [self.newBook1, self.book2, self.book3, self.book4, self.book5]
            
            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }

    //*****************************************************************************************
    //************************************DELETE TESTS*****************************************
    //*****************************************************************************************
    //MARK: - Delete all
    func testCase9() {
        
        let deletedBooks: [Book] = self.initialBooks
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = DeleteOperation<Book>(newData: self.initialState, array: deletedBooks) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == 0)
            XCTAssertTrue(deletings.count == deletedBooks.count)
            XCTAssertTrue(insertings.count == 0)
            XCTAssertTrue(movings.count == 0)
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = []
            
            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }
    
    //MARK: - Delete nothing
    func testCase10() {
        
        let deletedBooks: [Book] = []
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = DeleteOperation<Book>(newData: self.initialState, array: deletedBooks) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == self.initialBooks.count)
            XCTAssertTrue(deletings.count == deletedBooks.count)
            XCTAssertTrue(insertings.count == 0)
            XCTAssertTrue(movings.count == 0)
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = self.initialBooks
            
            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }
    
    //MARK: - Delete one
    func testCase11() {
        
        let deletedBooks: [Book] = [self.book2]
        
        let operationCompletion = expectation(description: "Operation completion")
        
        let operation = DeleteOperation<Book>(newData: self.initialState, array: deletedBooks) { (data, deletings, insertings, movings) in
            
            XCTAssertTrue(data.count == self.initialBooks.count - deletedBooks.count)
            XCTAssertTrue(deletings.count == deletedBooks.count)
            XCTAssertTrue(insertings.count == 0)
            XCTAssertTrue(movings.count == 0)
            
            var resultBooks: [Book] = []
            var allIndexPaths = data.keyEnumerator().allObjects as! [NSIndexPath]
            allIndexPaths = allIndexPaths.sorted { $0.row < $1.row }
            for indexPath in allIndexPaths {
                resultBooks.append(data.object(forKey: indexPath)! as Book)
            }
            
            let expectedResult: [Book] = [self.book1, self.book3]

            XCTAssertTrue(isArraysEqual(first: resultBooks, second: expectedResult))
            operationCompletion.fulfill()
        }
        
        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 4, handler: nil)
    }
}
