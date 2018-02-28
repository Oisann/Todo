//
//  Item.swift
//  Todo
//
//  Created by Trainee on 16/02/2018.
//  Copyright © 2018 Trainee. All rights reserved.
//

import Foundation
import CoreData

@objc(Item)
class Item: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var done: Bool
    @NSManaged var group: String
    
    func setup(name: String, done: Bool, group: String) {
        self.name = name
        self.done = done
        self.group = group
    }
}
