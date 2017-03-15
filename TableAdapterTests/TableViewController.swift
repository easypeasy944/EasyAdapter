//
//  TableViewController.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 4.декабря.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import UIKit
@testable import EasyAdapter

class TableViewController: UIViewController, UITableViewDataSource, IReloadable {

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    lazy var tableAdapter: EasyAdapter<Book> = {
        let adapter = EasyAdapter<Book>(tableView: self.tableView, referenced: MemoryOption.weakMemory, delegate: self)
        return adapter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
    }
    
    override func viewWillLayoutSubviews() {
        self.tableView.frame = self.view.bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableAdapter.dataCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = self.tableAdapter[indexPath as NSIndexPath]?.name
        return cell!
    }
    
    func tableView<T>(_ tableView: UITableView, configureCell cell: UITableViewCell, indexPath: NSIndexPath, data: T) {
        
    }
}
