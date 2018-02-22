//
//  ItemViewController.swift
//  Todo
//
//  Created by Trainee on 20/02/2018.
//  Copyright © 2018 Trainee. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {
    
    var newItem: Item!
    var oldItem: Item?
    var onSaveItem: ((_ old: Item?, _ new: Item) -> Void)?
    
    var nameField, sectionField: UITextField!
    var toggleDone: UISwitch!
    
    @objc func saveItem() {
        guard let newName = nameField.text, !newName.isEmpty, let newGroup = sectionField.text, !newGroup.isEmpty else { return }
        if (newName != oldItem?.name || newGroup != oldItem?.group || toggleDone.isOn != oldItem?.done) || oldItem == nil {
            newItem = Item(name: newName, done: toggleDone.isOn, group: newGroup)
            onSaveItem?(oldItem, newItem)
            navigationController?.popViewController(animated: true)
        }
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
        sectionField.text = oldItem?.group
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
