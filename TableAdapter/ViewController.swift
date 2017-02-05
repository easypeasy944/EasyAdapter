//
//  ViewController.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 6.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate lazy var tableAdapter: TableAdapter<Book> = {
        return TableAdapter<Book>(tableView: self.tableView, referenced: MemoryOption.weakMemory)
    }()
    var books: [Book] = []
    
    var prevBooks: [Book] = {
        var books: [Book] = []
        books.append(Book.init(id: "1", name: "1 Book"))
        books.append(Book.init(id: "2", name: "2 Book"))
        books.append(Book.init(id: "3", name: "3 Book"))
        books.append(Book.init(id: "4", name: "4 Book"))
        books.append(Book.init(id: "5", name: "5 Book"))
        return books
    }()
    
    var newBooks: [Book] = {
        var books: [Book] = []
        books.append(Book.init(id: "6", name: "1 Book"))
        books.append(Book.init(id: "4", name: "New 4 Book"))
        books.append(Book.init(id: "7", name: "3 Book"))
        books.append(Book.init(id: "8", name: "2 Book"))
        books.append(Book.init(id: "10", name: "5 Book"))
        return books
    }()
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateBooks()
        //self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }
    
    override func viewWillLayoutSubviews() {
        self.tableView.contentInset = UIEdgeInsets.zero
    }
    
    @IBAction func reload(_ sender: AnyObject) {
        NSLog("Reload")
        var books: [Book] = []
        for i in 0..<self.books.count {
            if arc4random()%2 == 0 { // Don't use condition for waves effect
                books.append(self.books[i])
            }
        }
        self.tableAdapter.set(data: books)
    }
    
    func update() {

        let choose = arc4random()%3
        
        switch choose {
        case 0:
            var books: [Book] = []
            for i in 0..<self.books.count {
                if arc4random()%2 == 0 { // Don't use condition for waves effect
                    books.append(self.books[i])
                }
            }
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).sync {
                self.tableAdapter.set(data: books)
            }
        case 1:
            var books: [Book] = []
            for i in 0..<self.books.count {
                if arc4random()%2 == 0 { // Don't use condition for waves effect
                    books.append(self.books[i])
                }
            }
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).sync {
                self.tableAdapter.insert(array: books)
            }
        case 2:
            var books: [Book] = []
            for i in 0..<self.books.count {
                if arc4random()%2 == 0 { // Don't use condition for waves effect
                    books.append(self.books[i])
                }
            }
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).sync {
                self.tableAdapter.delete(array: books)
            }
        default:
            return
        }
    }
    
    func generateBooks() {
        let count = 100
        for _ in 0..<count {
            
            let name = randomString(length: Int(arc4random_uniform(150) + 10))
            self.books.append(Book(name: name))
        }
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Log("Count - \(self.tableAdapter.tableData.count)")
        return self.tableAdapter.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! BookCell
        Log("Cell - \(indexPath)")
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Log("\(indexPath)")
        
        if let lCell = cell as? BookCell {
            let book = self.tableAdapter[indexPath]
            lCell.bookLabel.text = book?.name
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    
        let book = self.tableAdapter[indexPath]
        
        let rect = NSString(string: book?.name ?? "").boundingRect(with: CGSize(width: tableView.frame.size.width - 16, height: CGFloat.greatestFiniteMagnitude),
                                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                    attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)],
                                                                    context: nil)
        
        return ceil(rect.size.height) + 16
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let book = self.tableAdapter[indexPath]
        
        let rect = NSString(string: book?.name ?? "").boundingRect(with: CGSize(width: tableView.frame.size.width - 16, height: CGFloat.greatestFiniteMagnitude),
                                                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                   attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)],
                                                                   context: nil)
        
        Log("Height - \(indexPath) - \(ceil(rect.size.height) + 16)")
        
        return ceil(rect.size.height) + 16
    }
}
