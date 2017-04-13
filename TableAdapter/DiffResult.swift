//
//  DiffResult.swift
//  EasyAdapter
//
//  Created by Aynur Galiev on 13.04.17.
//  Copyright © 2017 Aynur Galiev. All rights reserved.
//

import Foundation

struct DiffResult {
    
    struct Rows {
        var deletions     : [IndexPath] = []
        var insertions    : [IndexPath] = []
        var modifications : [IndexPath] = []
        var moves         : [IndexPath] = []
    }
    
    struct Sections {
        var deletions     : [Int] = []
        var insertions    : [Int] = []
        var modifications : [Int] = []
        var moves         : [Int] = []
    }
    
    //MARK: - Private variables
    private var rows     : Rows
    private var sections : Sections
    
    init(rows: Rows, sections: Sections) {
        self.rows = rows
        self.sections = sections
    }
}
