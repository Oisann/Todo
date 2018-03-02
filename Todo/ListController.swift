//
//  ViewController.swift
//  Todo
//
//  Created by Trainee on 16/02/2018.
//  Copyright © 2018 Trainee. All rights reserved.
//

import UIKit
import CoreData

class ListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var itemTable: UITableView!
    //var keys: [String] = []
    //var items: [String:[Item]] = [:]
    var groups: [Group] = []
    var initialFetch: Bool = false
    
    struct ItemIndexPath {
        let item: Item
        let indexPath: IndexPath
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    func keyForSection(_ section: Int) -> String {
        return groups[section].name
    }
    
    func sectionForGroup(_ group: Group) -> Int {
        return groups.index(of: group) ?? 0
    }
    
    func indexPathForSection(_ item: Item) -> IndexPath {
        return IndexPath(row: item.group.items.count - 1, section: sectionForGroup(item.group))
    }
    
    func addSectionIfNew(_ group: Group) {
        if group.objectID.isTemporaryID {
            let pos = self.sectionForGroup(group)
            self.itemTable.insertSections([pos], with: .automatic)
        }
    }
    
    func addItem(_ newItem: Item) {
        self.itemTable.beginUpdates()
        self.addSectionIfNew(newItem.group)
        self.itemTable.insertRows(at: [indexPathForSection(newItem)], with: .automatic)
        self.itemTable.endUpdates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ItemViewController {
            let oldOne = sender as? ItemIndexPath
            viewController.oldItem = oldOne?.item
            viewController.onSaveItem = {
                [unowned self] oldGroup, newItem in
                
                guard let oldGroup = oldGroup else {
                    if !self.groups.contains(newItem.group) {
                        self.groups.append(newItem.group)
                    }
                    self.addItem(newItem)
                    self.savePersistentContainer()
                    return
                }
                
                guard let old = oldOne else { return }
                
                self.itemTable.beginUpdates()
                let oldSection = self.sectionForGroup(oldGroup)
                if oldGroup != newItem.group && oldGroup.items.count == 0 {
                    self.itemTable.deleteSections([oldSection], with: .automatic)
                    self.groups.remove(at: oldSection)
                    self.removeGroup(group: oldGroup)
                }
                
                //self.itemTable.endUpdates()
                if !self.groups.contains(newItem.group) {
                    self.groups.append(newItem.group)
                }
                
                //self.itemTable.beginUpdates()
                self.addSectionIfNew(newItem.group)
                //self.itemTable.endUpdates()
                
                //self.itemTable.beginUpdates()
                
                if oldGroup != newItem.group {
                    self.itemTable.insertRows(at: [self.indexPathForSection(newItem)], with: .automatic)
                    self.itemTable.deleteRows(at: [old.indexPath], with: .automatic)
                } else {
                    self.itemTable.reloadRows(at: [old.indexPath], with: .automatic)
                }
                
                self.itemTable.endUpdates()
                
                self.savePersistentContainer()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keyForSection(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let currentItem = groups[indexPath.section].item(indexPath.item)
        cell.textLabel?.text = currentItem.name
        cell.selectionStyle = .none
        cell.accessoryType = currentItem.done ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: {
            [weak self] action, indexPath in
            guard let this = self else { return }
            let currentItem = this.groups[indexPath.section].item(indexPath.item)
            let alertController = UIAlertController(title: currentItem.name, message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
                alert in
                
                tableView.beginUpdates()
                var deleteSection = false
                if currentItem.group.items.count == 1 {
                    self?.groups.remove(at: self?.sectionForGroup(currentItem.group) ?? 0)
                    self?.removeGroup(group: currentItem.group)
                    deleteSection = true
                }
                
                self?.remove(item: currentItem)
                
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                if deleteSection {
                    tableView.deleteSections([indexPath.section], with: .automatic)
                }
                self?.savePersistentContainer()
                tableView.endUpdates()
            }))
            alertController.addAction(UIAlertAction(title: "Keep", style: .default, handler: nil))
            this.present(alertController, animated: true, completion: nil)
        })
        let edit = UITableViewRowAction(style: .normal, title: "Edit", handler: {
            [weak self] action, indexPath in
            guard let this = self else { return }
            let currentItem = this.groups[indexPath.section].item(indexPath.item)
            this.performSegue(withIdentifier: "itemSegue", sender: ItemIndexPath(item: currentItem, indexPath: indexPath))
        })
        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentItem = groups[indexPath.section].item(indexPath.item)
        currentItem.done = !currentItem.done
        itemTable.updateTableView(at: [indexPath], change: .reload)
    }
    
    func handleListItem(title: String, nameFieldHandler: ((UITextField) -> Void)?, sectionFieldHandler: ((UITextField) -> Void)?, saveHandler: ((UIAlertAction, UITextField?, String) -> Void)?) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {
            textField in
            nameFieldHandler?(textField)
        })
        alertController.addTextField(configurationHandler: {
            textField in
            sectionFieldHandler?(textField)
        })
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alertAction in
            saveHandler?(alertAction, alertController.textFields?.first, alertController.textFields?.last?.text ?? "Default")
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func remove(item: Item) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(item)
    }
    
    func removeGroup(group: Group) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(group)
    }
    
    func savePersistentContainer() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
         } catch let error as NSError {
            print("Could not save. \(error.userInfo)")
         }
    }
    
    @objc func addListItem() {
        
        self.performSegue(withIdentifier: "itemSegue", sender: nil)
        
        /*
        handleListItem(title: "New item", nameFieldHandler: {
            textField in
            textField.placeholder = "Name"
        }, sectionFieldHandler: {
            textField in
            textField.placeholder = "Section"
        }, saveHandler: {
            [weak self] alertAction, textField, key in
            guard let text = textField?.text else { return }
            if text.isEmpty {
                return
            }
            self?.itemTable.beginUpdates()
            var section = self?.keys.index(of: key) ?? 0
            if self?.items[key] == nil {
                self?.keys.append(key)
                section = self?.keys.index(of: key) ?? 0
                self?.items.updateValue([], forKey: key)
                self?.itemTable.insertSections([section], with: .automatic)
            }
            let count = self?.items[key]?.count ?? 0
            self?.items[key]?.append(Item(name: text, done: false, group: key))
            self?.itemTable.insertRows(at: [IndexPath(row: count, section: section)], with: .automatic)
            self?.itemTable.endUpdates()
        })
        */
    }
    
    /*
    func editListItem(at: IndexPath) {
        handleListItem(title: "Edit item", nameFieldHandler: {
                [weak self] textField in
                guard let key = self?.keyForSection(at.section), let currentItem = self?.items[key]?[at.item] else { return }
                textField.placeholder = currentItem.name
                textField.text = currentItem.name
            }, sectionFieldHandler: {
                [weak self] textField in
                guard let key = self?.keyForSection(at.section), let currentItem = self?.items[key]?[at.item] else { return }
                textField.placeholder = currentItem.group
                textField.text = currentItem.group
            }, saveHandler: {
                [weak self] alertAction, textField, new_key in
                guard let text = textField?.text, let old_key = self?.keyForSection(at.section), let currentItem = self?.items[old_key]?[at.item] else { return }
                if text.isEmpty {
                    return
                }
                print(text)
                print(new_key)
                self?.itemTable.beginUpdates()
                if self?.items[new_key] == nil {
                    self?.keys.append(new_key)
                    self?.items.updateValue([], forKey: new_key)
                    self?.itemTable.insertSections([self?.sectionForKey(new_key) ?? 0], with: .automatic)
                }
                
                let section = self?.keys.index(of: new_key) ?? 0
                
                currentItem.name = text
                currentItem.group = new_key
                
                if old_key != new_key {
                    self?.items[new_key]?.append(currentItem)
                    self?.items[old_key]?.remove(at: at.item)
                }
                
                if let count = self?.items[old_key]?.count, count == 0 {
                    self?.keys.remove(at: at.section)
                    self?.items.removeValue(forKey: old_key)
                    self?.itemTable.deleteSections([at.section], with: .automatic)
                }
                
                if old_key == new_key {
                    self?.itemTable.reloadRows(at: [at], with: .automatic)
                } else {
                    let count = self?.items[new_key]?.count ?? 0
                    self?.itemTable.insertRows(at: [IndexPath(row: count - 1, section: section)], with: .automatic)
                    self?.itemTable.deleteRows(at: [at], with: .automatic)
                }
                
                self?.itemTable.endUpdates()
        })
    }
    */
    
    @objc func orientationDidChange(notification: Notification) {
        view.setNeedsUpdateConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !initialFetch {
            
            let table = UITableView(frame: view.bounds, style: .plain)
            view.addSubview(table)
            table.dataSource = self
            table.delegate = self
            table.translatesAutoresizingMaskIntoConstraints = false
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            table.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            itemTable = table
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<Group>(entityName: "Group")
            
            do {
                groups = try managedContext.fetch(fetchRequest).map({ $0 as Group })
                itemTable.reloadData()
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            initialFetch = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todo"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addListItem))
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
