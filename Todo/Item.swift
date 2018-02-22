//
//  Item.swift
//  Todo
//
//  Created by Trainee on 16/02/2018.
//  Copyright © 2018 Trainee. All rights reserved.
//

import Foundation

class Item {
    var name: String
    var done: Bool
    var group: String
    
    init(name: String, done: Bool, group: String) {
        self.name = name
        self.done = done
        self.group = group
    }
}
