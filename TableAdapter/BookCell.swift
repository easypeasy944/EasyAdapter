//
//  BookCell.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 6.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import UIKit

public class BookCell: UITableViewCell {

    @IBOutlet weak var bookLabel: UILabel!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.bookLabel.frame = self.bounds.insetBy(dx: 8, dy: 8)
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        self.frame.size.height = -1
//    }
}
