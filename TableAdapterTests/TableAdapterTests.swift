//
//  TableAdapterTests.swift
//  TableAdapterTests
//
//  Created by Aynur Galiev on 6.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import XCTest
@testable import TableAdapter

class TableAdapterTests: XCTestCase {
    
    private var viewController: TableViewController!
    
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
    
    override func setUp() {
        super.setUp()
        self.viewController = TableViewController()
        UIApplication.shared.keyWindow?.rootViewController = self.viewController
    }
    
    override func tearDown() {
        super.tearDown()
        self.viewController = nil
        UIApplication.shared.keyWindow?.rootViewController = nil
    }
    
    func testSetWithUpdate() {
        
        //Initial data
        var books = [book1, book2, book3]
        
        var expect = expectation(description: "")
        self.viewController.tableAdapter.set(data: books, update: true)
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(5)) { 
            expect.fulfill()
        }
        waitForExpectations(timeout: 6, handler: nil)
        
        var updatedBooks: [Book] = []
        var keys = self.viewController.tableAdapter.tableData.keyEnumerator().allObjects as! [IndexPath]
        keys = keys.sorted()
        for key in keys {
            let book = self.viewController.tableAdapter.tableData.object(forKey: key as NSIndexPath?)! as Book
            updatedBooks.append(book)
        }

        XCTAssertTrue(self.isArraysEqual(first: books, second: updatedBooks), "Arrays not equal")
        
        //Filling with test data with updating
        books = [newBook1, newBook2, newBook3]
        expect = expectation(description: "")
        self.viewController.tableAdapter.set(data: books, update: true)
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(5)) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 6, handler: nil)
        
        updatedBooks = []
        keys = self.viewController.tableAdapter.tableData.keyEnumerator().allObjects as! [IndexPath]
        keys = keys.sorted()
        for key in keys {
            let book = self.viewController.tableAdapter.tableData.object(forKey: key as NSIndexPath?)! as Book
            updatedBooks.append(book)
        }
        XCTAssertTrue(self.isArraysEqual(first: books, second: updatedBooks), "Arrays not equal")
    }
    
    func testSetWithoutUpdate() {
        
        //Initial data
        var books = [book1, book2, book3]
        
        var expect = expectation(description: "")
        self.viewController.tableAdapter.set(data: books, update: true)
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(5)) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 6, handler: nil)
        
        var updatedBooks: [Book] = []
        var keys = self.viewController.tableAdapter.tableData.keyEnumerator().allObjects as! [IndexPath]
        keys = keys.sorted()
        for key in keys {
            let book = self.viewController.tableAdapter.tableData.object(forKey: key as NSIndexPath?)! as Book
            updatedBooks.append(book)
        }
        
        XCTAssertTrue(self.isArraysEqual(first: books, second: updatedBooks), "Arrays not equal")
        
        //Filling with test data without updating
        books = [newBook1, newBook2, newBook3]
        expect = expectation(description: "")
        self.viewController.tableAdapter.set(data: books, update: false)
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(5)) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 6, handler: nil)
        
        updatedBooks = []
        keys = self.viewController.tableAdapter.tableData.keyEnumerator().allObjects as! [IndexPath]
        keys = keys.sorted()
        for key in keys {
            let book = self.viewController.tableAdapter.tableData.object(forKey: key as NSIndexPath?)! as Book
            updatedBooks.append(book)
        }
        XCTAssertTrue(self.isArraysEqual(first: updatedBooks, second: [book1, book2, book3]), "Arrays not equal")
    }
    
    func isArraysEqual(first: [Book], second: [Book]) -> Bool {
        guard first.count == second.count else { return false }
        for i in 0..<first.count {
            guard first[i] == second[i] else { return false }
        }
        return true
    }
    
    func testInsert() {

        //Initial data
        var books = [book1, book2, book3]
        
        var expect = expectation(description: "")
        self.viewController.tableAdapter.set(data: books, update: true)
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(5)) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 6, handler: nil)
        
        var updatedBooks: [Book] = []
        var keys = self.viewController.tableAdapter.tableData.keyEnumerator().allObjects as! [IndexPath]
        keys = keys.sorted()
        for key in keys {
            let book = self.viewController.tableAdapter.tableData.object(forKey: key as NSIndexPath?)! as Book
            updatedBooks.append(book)
        }
        
        XCTAssertTrue(self.isArraysEqual(first: books, second: updatedBooks), "Arrays not equal")
        
        //Filling with test data with updating
        books = [book1, newBook2, newBook3, book5]
        expect = expectation(description: "")
        self.viewController.tableAdapter.insertArray(array: books, updateExisting: true)
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(5)) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 6, handler: nil)
        
        updatedBooks = []
        keys = self.viewController.tableAdapter.tableData.keyEnumerator().allObjects as! [IndexPath]
        keys = keys.sorted()
        for key in keys {
            let book = self.viewController.tableAdapter.tableData.object(forKey: key as NSIndexPath?)! as Book
            updatedBooks.append(book)
        }
        XCTAssertTrue(self.isArraysEqual(first: updatedBooks, second: books), "Arrays not equal")
        
    }
    
}
