//
//  IReloadable.swift
//  EasyAdapter
//
//  Created by Aynur Galiev on 13.04.17.
//  Copyright © 2017 Aynur Galiev. All rights reserved.
//

import UIKit

protocol IReloadable: class {
    func tableView<T>(_ tableView: UITableView,
                   configureCell cell: UITableViewCell,
                   indexPath: NSIndexPath,
                   data: T)
}
