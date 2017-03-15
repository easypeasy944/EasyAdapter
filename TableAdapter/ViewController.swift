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
    fileprivate lazy var tableAdapter: EasyAdapter<Book> = {
        return EasyAdapter<Book>(tableView: self.tableView, referenced: MemoryOption.weakMemory, delegate: self)
    }()
    var books: [Book] = []
    var minimumLength: UInt32 = 10
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateBooks()
//        self.tableView.estimatedRowHeight = 44
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }
    
    override func viewWillLayoutSubviews() {
        self.tableView.contentInset = UIEdgeInsets.zero
    }
    
    @IBAction func reload(_ sender: AnyObject) {
        //NSLog("Reload")
        var books: [Book] = []
        for i in 0..<self.books.count {
            if arc4random()%2 == 0 {
                books.append(self.books[i])
            }
        }
        self.tableAdapter.set(data: books)
    }
    
    func update() {

        let choose = arc4random() % 4
        
        switch choose {
        case 0:
            var books: [Book] = []
            for i in 0..<self.books.count {
                if arc4random()%2 == 0 {
                    books.append(self.books[i])
                }
            }
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).sync {
                self.tableAdapter.set(data: books)
            }
        case 1:
            var books: [Book] = []
            for i in 0..<self.books.count {
                if arc4random()%2 == 0 {
                    books.append(self.books[i])
                }
            }
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).sync {
                self.tableAdapter.insert(array: books)
            }
        case 2:
            var books: [Book] = []
            for i in 0..<self.books.count {
                if arc4random()%2 == 0 {
                    books.append(self.books[i])
                }
            }
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).sync {
                self.tableAdapter.delete(array: books)
            }
        case 3:
            DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).sync {
                let sliceIndex: Int = Int(arc4random() % self.minimumLength)
                self.tableAdapter.set(sortBlock: { (first: Book, second: Book) -> Bool in
                    
                    let startIndexFirst = first.name.index(first.name.startIndex, offsetBy: sliceIndex)
                    let firstPart = first.name.substring(from: startIndexFirst)
                    
                    let startIndexSecond = second.name.index(second.name.startIndex, offsetBy: sliceIndex)
                    let secondPart = second.name.substring(from: startIndexSecond)
                    
                    return firstPart < secondPart
                })
            }
            
        default:
            return
        }
    }
    
    func generateBooks() {
        let count = 100
        for _ in 0..<count {
            
            let name = randomString(length: Int(arc4random_uniform(150)+self.minimumLength))
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
        return self.tableAdapter.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BookCell! = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! BookCell
        if cell == nil {
            print("Cell is nil")
        }
        return cell
    }
}

extension ViewController: IReloadable {
    
    func tableView<T>(_ tableView: UITableView, configureCell cell: UITableViewCell, indexPath: NSIndexPath, data: T) {
        if let cell = cell as? BookCell {
            let book = self.tableAdapter[indexPath as NSIndexPath]
            cell.contentView.fadeTransition(duration: 0.2)
            cell.bookLabel.text = book?.name
        }
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lCell = cell as? BookCell {
            let book = self.tableAdapter[indexPath as NSIndexPath]
            lCell.bookLabel.text = book?.name
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    
        let book = self.tableAdapter[indexPath as NSIndexPath]
        
        let rect = NSString(string: book?.name ?? "").boundingRect(with: CGSize(width: tableView.frame.size.width - 16, height: CGFloat.greatestFiniteMagnitude),
                                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                    attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)],
                                                                    context: nil)
        
        return ceil(rect.size.height) + 16
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let book = self.tableAdapter[indexPath as NSIndexPath]
        
        let rect = NSString(string: book?.name ?? "").boundingRect(with: CGSize(width: tableView.frame.size.width - 16, height: CGFloat.greatestFiniteMagnitude),
                                                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                   attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)],
                                                                   context: nil)
        return ceil(rect.size.height) + 16
    }
}
