//
//  ItemViewController.swift
//  Todo
//
//  Created by Trainee on 20/02/2018.
//  Copyright © 2018 Trainee. All rights reserved.
//

import UIKit
import CoreData

class ItemViewController: UIViewController {
    
    var newItem: Item!
    var oldItem: Item? {
        didSet {
            if let group = oldItem?.group {
                oldGroup = group
            }
        }
    }
    var oldGroup: Group!
    var onSaveItem: ((_ old: Group?, _ new: Item) -> Void)?
    
    var nameField, sectionField: UITextField!
    var toggleDone: UISwitch!
    
    @objc func saveItem() {
        guard let newName = nameField.text, !newName.isEmpty, let newGroup = sectionField.text, !newGroup.isEmpty else { return }
        if (newName != oldItem?.name || newGroup != oldGroup.name || toggleDone.isOn != oldItem?.done) || oldItem == nil {
            //newItem = Item(name: newName, done: toggleDone.isOn, group: newGroup)
            guard let newestItem = save(name: newName, done: toggleDone.isOn, group: newGroup) else { return }
            newItem = newestItem
            onSaveItem?(oldGroup, newItem)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func save(name: String, done: Bool, group: String) -> Item? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        var item: Item
        
        if let unwrapped = oldItem {
            item = unwrapped
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext)!
            item = NSManagedObject(entity: entity, insertInto: managedContext) as! Item
        }
        
        let fetchRequest = NSFetchRequest<Group>(entityName: "Group")
        fetchRequest.predicate = NSPredicate(format: "name == %@", group)
        
        do {
            if let fetchedGroup = try managedContext.fetch(fetchRequest).map({ $0 as Group }).first {
                item.group = fetchedGroup
            } else {
                let entity = NSEntityDescription.entity(forEntityName: "Group", in: managedContext)!
                item.group = NSManagedObject(entity: entity, insertInto: managedContext) as! Group
                item.group.setup(name: group)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        item.setup(name: name, done: done, sort: item.group.items.count)
        
        return item
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let stack = UIStackView(frame: view.bounds.insetBy(dx: 10, dy: view.safeAreaInsets.top))
        stack.axis = .vertical
        stack.spacing = 5
        stack.distribution = .fillProportionally
        view.addSubview(stack)
        
        let labelName = UILabel()
        labelName.text = "Name:"
        labelName.translatesAutoresizingMaskIntoConstraints = false
        labelName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stack.addArrangedSubview(labelName)
        
        nameField = UITextField()
        nameField.placeholder = "Name"
        nameField.text = oldItem?.name
        nameField.borderStyle = .roundedRect
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        stack.addArrangedSubview(nameField)
        
        let labelSection = UILabel()
        labelSection.text = "Section:"
        labelSection.translatesAutoresizingMaskIntoConstraints = false
        labelSection.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stack.addArrangedSubview(labelSection)
        
        sectionField = UITextField()
        sectionField.placeholder = "Section"
        sectionField.text = oldItem?.group.name
        sectionField.borderStyle = .roundedRect
        sectionField.translatesAutoresizingMaskIntoConstraints = false
        sectionField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        stack.addArrangedSubview(sectionField)
        
        toggleDone = UISwitch()
        toggleDone.isOn = oldItem?.done ?? false
        stack.addArrangedSubview(toggleDone)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItem))
    }
    
    override func viewDidLoad() {
        guard let oldName = oldItem?.name else {
            title = "New item"
            return
        }
        title = oldName
    }
}
