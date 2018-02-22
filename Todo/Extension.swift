//
//  Extension.swift
//  Todo
//
//  Created by Trainee on 19/02/2018.
//  Copyright © 2018 Trainee. All rights reserved.
//

import UIKit

extension UITableView {
    
    enum RowChange {
        case insert
        case remove
        case reload
    }
    
    func updateTableView(at: [IndexPath], change: RowChange) {
        self.beginUpdates()
        switch change {
        case .insert:
            self.insertRows(at: at, with: .automatic)
            break
        case .remove:
            self.deleteRows(at: at, with: .automatic)
            break
        case .reload:
            self.reloadRows(at: at, with: .automatic)
            break
        }
        self.endUpdates()
    }
}
