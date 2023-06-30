//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//  Cloned by Ezagor on 06/12/2023.
//

import UIKit
import RealmSwift
import SwipeCellKit


class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    func calculateContrastColor(forColor color: UIColor) -> UIColor {
        guard let components = color.cgColor.components else {
            return .black
        }
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        let threshold: CGFloat = 0.5
        let luminance = (red * 0.299) + (green * 0.587) + (blue * 0.114)
        
        return luminance > threshold ? .black : .white
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = .black
            cell.selectedBackgroundView = selectedBackgroundView
        if cell.contentView.layer.cornerRadius != 10.0 {
                // Set the corner radius of the cell's content view
                cell.contentView.layer.cornerRadius = 10.0
            }
        let verticalPadding: CGFloat = 10.0
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.white.cgColor
        maskLayer.cornerRadius = 10.0
        maskLayer.frame = CGRect(
            x: cell.contentView.frame.origin.x,
            y: cell.contentView.frame.origin.y + verticalPadding,
            width: cell.contentView.frame.width,
            height: cell.contentView.frame.height - (2 * verticalPadding)
        )
        cell.contentView.layer.mask = maskLayer
        cell.contentView.layer.masksToBounds = true
    }

    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour{
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else{
                fatalError("Navigation controller does not exist.")}
            if let colorHex = selectedCategory?.colour, let navBarColour = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navBarColour
                let contrastColor = calculateContrastColor(forColor: navBarColour)
                navBar.tintColor = contrastColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
                searchBar.barTintColor = UIColor(hexString: selectedCategory!.colour)
                searchBar.searchTextField.backgroundColor = UIColor.white
            }
        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 // Set an initial estimated height for better performance
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            cell.textLabel?.lineBreakMode = .byWordWrapping
                    cell.textLabel?.numberOfLines = 0

            if let categoryColor = UIColor(hexString: selectedCategory?.colour ?? "") {
                let contrastColor = calculateContrastColor(forColor: categoryColor)
                cell.contentView.layer.borderWidth = 1.0
                cell.contentView.layer.borderColor = categoryColor.cgColor
                cell.contentView.layer.backgroundColor = categoryColor.cgColor
                cell.textLabel?.textColor = indexPath.row == 0 && isColorDark(categoryColor) ? .black : contrastColor
                cell.tintColor = .white
//                cell.accessoryView?.tintColor = contrastColor
            } else {
                // Set a default border color if the category color is invalid
                cell.contentView.layer.borderWidth = 1.0
                cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
                cell.textLabel?.textColor = .black
            }

            let startColor = UIColor(hexString: selectedCategory?.colour ?? "") ?? UIColor(red: 152/255, green: 238/255, blue: 204/255, alpha: 1.0)
            let maxItems = CGFloat(todoItems?.count ?? 1)
            let percentage = CGFloat(indexPath.row) / maxItems
            let endColor = startColor.darken(byPercentage: 0.3 + (0.4 * percentage))

            if item.isPinned {
                cell.backgroundColor = endColor
                cell.textLabel?.textColor = calculateContrastColor(forColor: endColor)
            } else {
                cell.backgroundColor = endColor
                cell.textLabel?.textColor = calculateContrastColor(forColor: endColor)
            }
        } else {
            cell.textLabel?.text = "No Items Added"
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
            cell.textLabel?.textColor = .black
            cell.backgroundColor = UIColor(hexString: "79C0D0")
            cell.textLabel?.lineBreakMode = .byTruncatingTail // Truncate the text if no item is added
                cell.textLabel?.numberOfLines = 1

        }

        // Set the background color of the cell
        cell.backgroundColor = .black
//        cell.accessoryView?.tintColor = .white

        return cell
    }

    func isColorDark(_ color: UIColor) -> Bool {
        guard let components = color.cgColor.components else {
            return false
        }

        let red = components[0]
        let green = components[1]
        let blue = components[2]

        let threshold: CGFloat = 0.5
        let luminance = (red * 0.299) + (green * 0.587) + (blue * 0.114)

        return luminance < threshold
    }










    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    //                    realm.delete(item)            DELETE
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: Edit Data From Swipe
    
    
    override func editModel(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
        var textField = UITextField()

        let action = UIAlertAction(title: "Update", style: .default) { (action) in
            if let newItemName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
               !newItemName.isEmpty, let item = self.todoItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        item.title = newItemName.capitalized
                    }
                } catch {
                    print("Error updating item: \(error)")
                }
                self.tableView.reloadData()
            } else {
                // Show an error message indicating that the name cannot be empty
                let errorAlert = UIAlertController(title: "Error", message: "Item name cannot be empty.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                errorAlert.addAction(okAction)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addTextField { (field) in
            textField = field
            textField.text = self.todoItems?[indexPath.row].title
            textField.autocapitalizationType = .sentences
        }

        alert.addAction(action)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        
        if let itemForDeletion = self.todoItems?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(itemForDeletion)
                }
            }catch{
                print("Error deleting category, \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updateModel(at: indexPath)
        }
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            self.editModel(at: indexPath)
        }
        
        let pinAction = SwipeAction(style: .default, title: "Pin") { action, indexPath in
            self.pinItem(at: indexPath)
        }
        
        // Customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        editAction.image = UIImage(systemName: "pencil")
        pinAction.image = UIImage(systemName: "pin.fill")
        
        editAction.backgroundColor = .blue
            pinAction.backgroundColor = .gray
        
        return [deleteAction, editAction, pinAction]
    }

    
    func pinItem(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.isPinned = !item.isPinned
                    
                    let allItems = realm.objects(Item.self).sorted(byKeyPath: "isPinned", ascending: false)
                    let pinnedItems = allItems.filter("isPinned == true")
                    let unpinnedItems = allItems.filter("isPinned == false")
                    
                    let concatenatedItems = Array(pinnedItems) + Array(unpinnedItems)
                    todoItems = realm.objects(Item.self).filter("FALSEPREDICATE") // Empty filter to clear the previous Results object
                    todoItems = realm.objects(Item.self).sorted(byKeyPath: "isPinned", ascending: false)
                    
                    tableView.reloadData()
                }
            } catch {
                print("Error updating item pin status, \(error)")
            }
        }
    }


    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (_) in
                    let itemName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

                    if let name = itemName, !name.isEmpty, let currentCategory = self.selectedCategory {
                        do {
                            try self.realm.write {
                                let newItem = Item()
                                newItem.title = name.capitalized
                                newItem.dateCreated = Date()
                                currentCategory.items.append(newItem)
                            }
                        } catch {
                            print("Error saving new items, \(error)")
                        }
                    }else{
                        let errorAlert = UIAlertController(title: "Error", message: "Item name cannot be empty.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        errorAlert.addAction(okAction)
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                    
                    self.tableView.reloadData()
                }

                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                alert.addAction(addAction)
                alert.addAction(cancelAction)

                alert.addTextField { (alertTextField) in
                    textField = alertTextField
                    textField.placeholder = "Create new item"
                    textField.autocapitalizationType = .sentences
                }

                present(alert, animated: true, completion: nil)
            }

    
    //MARK - Model Manupulation Methods
    
    
    
    func loadItems() {
            if let category = selectedCategory {
                // Sort the items based on pin status and then by title
                todoItems = category.items.sorted(by: [
                    SortDescriptor(keyPath: "isPinned", ascending: false),
                    SortDescriptor(keyPath: "title", ascending: true)
                ])
            }
            
            tableView.reloadData()
        }
    
}

//MARK: - Search bar methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated",ascending: true)
        
        tableView.reloadData()
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
  
    }
    
    
    
    
    
}

