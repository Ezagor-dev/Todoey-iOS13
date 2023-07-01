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
    var pinnedItems: Results<Item>?
    var unpinnedItems: Results<Item>?
    
    
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
        return todoItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let minHeight: CGFloat = 80
        let defaultHeight: CGFloat = 44
        
        if let item = todoItems?[indexPath.row] {
            let text = item.title
            let labelWidth = tableView.bounds.width - 16 // Adjust the padding as needed
            let labelFont = UIFont.systemFont(ofSize: 17)
            let labelInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Adjust the insets as needed
            
            let label = UILabel()
            label.font = labelFont
            label.text = text
            label.numberOfLines = 0
            label.frame.size = CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
            label.sizeToFit()
            
            let lines = ceil(label.frame.height / label.font.lineHeight)
            let lineSpacing: CGFloat = 4 // Adjust the line spacing as needed
            let cellHeight = max(minHeight, (label.font.lineHeight * lines) + (lineSpacing * (lines - 1)) + labelInsets.top + labelInsets.bottom)
            
            return cellHeight
        }
        
        return defaultHeight
    }
    

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 // Set an initial estimated height for better performance
    }
    
    
    
    
    
    //cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Add the creation date label to the cell
        let creationDateLabel = UILabel()
        creationDateLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(creationDateLabel)
        
        // Set the creation date label constraints
        creationDateLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
        creationDateLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20).isActive = true
        creationDateLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10).isActive = true
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            
            
            
            // Display the creation date in the creation date label
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            let creationDate = item.dateCreated
            let creationDateString = dateFormatter.string(from: creationDate)
            
            creationDateLabel.text = "Created on \(creationDateString)"
            
            // Customize the appearance of the creation date label
            creationDateLabel.font = UIFont.italicSystemFont(ofSize: 12)
            creationDateLabel.textColor = UIColor.gray
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let categoryColor = UIColor(hexString: selectedCategory?.colour ?? "") {
                let contrastColor = calculateContrastColor(forColor: categoryColor)
                cell.contentView.layer.borderWidth = 1.0
                cell.contentView.layer.borderColor = categoryColor.cgColor
                cell.contentView.layer.backgroundColor = categoryColor.cgColor
                cell.textLabel?.textColor = isColorDark(categoryColor) ? contrastColor : .black
                cell.tintColor = .white
                
                // Update label's properties
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.textLabel?.preferredMaxLayoutWidth = tableView.bounds.width - 20
                
                // Adjust cell's height based on text length
                let font = UIFont.systemFont(ofSize: 17)
                let text = item.title
                let textHeight = text.boundingRect(with: CGSize(width: tableView.bounds.width - 20, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
                let minHeight: CGFloat = 44
                let cellHeight = max(minHeight, textHeight + 20)
                cell.frame.size.height = cellHeight
                
               
                
                
                
            } else {
                // Set a default border color if the category color is invalid
                cell.contentView.layer.borderWidth = 1.0
                cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
                cell.textLabel?.textColor = .black
            }
            
//            let startColor = UIColor(hexString: selectedCategory?.colour ?? "") ?? UIColor(red: 152/255, green: 238/255, blue: 204/255, alpha: 1.0)
//            let maxItems = CGFloat(todoItems?.count ?? 1)
//            let percentage = CGFloat(indexPath.row) / maxItems
//            let endColor = startColor.darken(byPercentage: 0.3 + (0.4 * percentage))
//
//            let gradientLayer = CAGradientLayer()
//                    gradientLayer.frame = cell.contentView.bounds
//                    gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
//                    cell.contentView.layer.insertSublayer(gradientLayer, at: 0)
//
//            if item.isPinned {
//                cell.backgroundColor = endColor
//                cell.textLabel?.textColor = calculateContrastColor(forColor: endColor)
//            } else {
//                cell.backgroundColor = endColor
//                cell.textLabel?.textColor = calculateContrastColor(forColor: endColor)
//            }
            
        } else {
            cell.textLabel?.text = "No Items Added"
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
            cell.textLabel?.textColor = .black
            cell.backgroundColor = UIColor(hexString: "79C0D0")
            cell.textLabel?.lineBreakMode = .byTruncatingTail // Truncate the text if no item is added
            cell.textLabel?.numberOfLines = 1 // Show only one line for the placeholder text
            creationDateLabel.text = ""
        }
        
        // Set the background color of the cell
        cell.backgroundColor = .black
        
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
        
        let pinActionTitle = todoItems?[indexPath.row].isPinned == true ? "Unpin" : "Pin"
            let pinAction = SwipeAction(style: .default, title: pinActionTitle) { action, indexPath in
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
    
    override func pinItem(at indexPath: IndexPath) {
        super.pinItem(at: indexPath)
        if let selectedCategory = selectedCategory, let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.isPinned = !item.isPinned
                }
                // Retrieve all items belonging to the selected category
                let allItems = selectedCategory.items.sorted(byKeyPath: "title", ascending: true)
                
                // Sort the items based on the pin status and title
                let pinnedItems = allItems.filter("isPinned == true").sorted(byKeyPath: "title", ascending: true)
                let unpinnedItems = allItems.filter("isPinned == false").sorted(byKeyPath: "title", ascending: true)
                let updatedItems = Array(pinnedItems) + Array(unpinnedItems)
                
                // Replace the items in the selected category with the updated sorted items
                try realm.write {
                    selectedCategory.items.removeAll()
                    selectedCategory.items.append(objectsIn: updatedItems)
                }
                
                tableView.reloadData()
                
               
            } catch {
                print("Error updating item pin status: \(error)")
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
            // Sort the items based on the pin status and then by title
            todoItems = category.items.sorted(by: [
                SortDescriptor(keyPath: "isPinned", ascending: false),
                SortDescriptor(keyPath: "title", ascending: true)
            ])
        }
    }
    
    
}

//MARK: - Search bar methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            filterItems(with: searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterItems(with: searchText)
    }
    
    private func filterItems(with searchText: String) {
        if searchText.isEmpty {
            // If the search text is empty, reload the table view to show all items
            loadItems()
        } else {
            // If there is a search text, filter the items based on the search text
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
        }
        
        tableView.reloadData()
    }
}
