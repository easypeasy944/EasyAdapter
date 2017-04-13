//
//  Adapter.swift
//  EasyAdapter
//
//  Created by Aynur Galiev on 13.04.17.
//  Copyright © 2017 Aynur Galiev. All rights reserved.
//

import UIKit

typealias DataSource<T: Data> = Dictionary<IndexPath, IWrapper<T>>

open class Adapter<T: Data> {
    
    //MARK: - Private variables
    private var data           : DataSource<T>
    private weak var tableView : UITableView?
    private weak var delegate  : IReloadable?
    
    init(tableView: UITableView, retainType: RetainType, delegate: IReloadable?) {
        self.tableView = tableView
        self.delegate = delegate
        self.data = DataSource<T>()
    }
}
