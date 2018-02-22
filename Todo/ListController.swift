//
//  ViewController.swift
//  Todo
//
//  Created by Trainee on 16/02/2018.
//  Copyright © 2018 Trainee. All rights reserved.
//

import UIKit

class ListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var itemTable: UITableView!
    var keys: [String] = ["test"]
    var items: [String:[Item]] = ["test":[Item(name: "hey", done: false, group: "test")]]
    
    struct ItemIndexPath {
        let item: Item
        let indexPath: IndexPath
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func keyForSection(_ section: Int) -> String {
        return keys[section]
    }
    
    func sectionForKey(_ key: String) -> Int {
        return keys.index(of: key) ?? 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ItemViewController {
            let oldOne = sender as? ItemIndexPath
            viewController.oldItem = oldOne?.item
            viewController.onSaveItem = {
                [weak self] oldItem, newItem in
                
                guard let oldItem = oldItem else {
                    self?.itemTable.beginUpdates()
                    var section = self?.keys.index(of: newItem.group) ?? 0
                    if self?.items[newItem.group] == nil {
                        self?.keys.append(newItem.group)
                        section = self?.keys.index(of: newItem.group) ?? 0
                        self?.items.updateValue([], forKey: newItem.group)
                        self?.itemTable.insertSections([section], with: .automatic)
                    }
                    let count = self?.items[newItem.group]?.count ?? 0
                    self?.items[newItem.group]?.append(newItem)
                    self?.itemTable.insertRows(at: [IndexPath(row: count, section: section)], with: .automatic)
                    self?.itemTable.endUpdates()
                    return
                }
                
                guard let old = oldOne else { return }
                if self?.items[newItem.group] == nil {
                    self?.itemTable.beginUpdates()
                    
                    self?.keys.append(newItem.group)
                    let pos = self?.keys.index(of: newItem.group) ?? 0
                    self?.items.updateValue([], forKey: newItem.group)
                    self?.itemTable.insertSections([pos], with: .automatic)
                    
                    self?.itemTable.endUpdates()
                }
                
                self?.itemTable.beginUpdates()
                let oldSection = self?.keys.index(of: oldItem.group) ?? 0
                var section = self?.keys.index(of: newItem.group) ?? 0
                
                if oldItem.group != newItem.group {
                    self?.items[newItem.group]?.append(newItem)
                    self?.items[oldItem.group]?.remove(at: old.indexPath.item)
                    
                    if let count = self?.items[oldItem.group]?.count, count == 0 {
                        self?.keys.remove(at: oldSection)
                        section = self?.keys.index(of: newItem.group) ?? 0
                        self?.items.removeValue(forKey: oldItem.group)
                        self?.itemTable.deleteSections([oldSection], with: .automatic)
                    }
                    let count = self?.items[newItem.group]?.count ?? 0
                    self?.itemTable.insertRows(at: [IndexPath(row: count - 1, section: section)], with: .automatic)
                    self?.itemTable.deleteRows(at: [old.indexPath], with: .automatic)
                } else {
                    self?.items[oldItem.group]?[old.indexPath.item] = newItem
                    self?.itemTable.reloadRows(at: [old.indexPath], with: .automatic)
                }
                
                self?.itemTable.endUpdates()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keyForSection(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keys[section]
        return items[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        guard let currentItem = items[keyForSection(indexPath.section)]?[indexPath.item] else { return cell }
        cell.textLabel?.text = currentItem.name
        cell.selectionStyle = .none
        cell.accessoryType = currentItem.done ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: {
            [weak self] action, indexPath in
            guard let this = self else { return }
            guard let currentItem = this.items[this.keyForSection(indexPath.section)]?[indexPath.item] else { return }
            let alertController = UIAlertController(title: currentItem.name, message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
                alert in
                this.items[currentItem.group]?.remove(at: indexPath.item)
                this.itemTable.updateTableView(at: [indexPath], change: .remove)
                if let section = this.items[currentItem.group], section.isEmpty {
                    this.items.removeValue(forKey: currentItem.group)
                    this.keys.remove(at: indexPath.section)
                    this.itemTable.reloadData()
                }
            }))
            alertController.addAction(UIAlertAction(title: "Keep", style: .default, handler: nil))
            this.present(alertController, animated: true, completion: nil)
        })
        let edit = UITableViewRowAction(style: .normal, title: "Edit", handler: {
            [weak self] action, indexPath in
            guard let this = self else { return }
            guard let currentItem = this.items[this.keyForSection(indexPath.section)]?[indexPath.item] else { return }
            //self?.editListItem(at: indexPath)
            self?.performSegue(withIdentifier: "itemSegue", sender: ItemIndexPath(item: currentItem, indexPath: indexPath))
        })
        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentItem = items[keyForSection(indexPath.section)]?[indexPath.item] else { return }
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
