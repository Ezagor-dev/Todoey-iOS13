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
        // Add a tap gesture recognizer to dismiss the keyboard when tapping elsewhere
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                tapGesture.cancelsTouchesInView = false
                tableView.addGestureRecognizer(tapGesture)

        //        tableView.separatorStyle = .none
        
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
          view.endEditing(true) // Close the keyboard
          
          // If the tap was outside the table view, deselect the selected row
          let location = gestureRecognizer.location(in: tableView)
          if let indexPath = tableView.indexPathForRow(at: location) {
              tableView.deselectRow(at: indexPath, animated: true)
          }
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
    
    
    
    
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Add spacing between rows
        let space: CGFloat = 10.0
            let inset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
            cell.frame = cell.frame.inset(by: inset)
        // Set the corner radius of the cell's content view
        cell.contentView.layer.cornerRadius = cell.contentView.frame.height / 2
        
        
        // Add a border to the cell's content view
        cell.contentView.layer.borderWidth = 1.0
        
        // Remove previous subviews from the cell's contentView
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
//            cell.accessoryType = item.done ? .checkmark : .none
            if item.done {
                            let checkmarkLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                            checkmarkLabel.text = "✅"
                            checkmarkLabel.textColor = .white
                            checkmarkLabel.font = UIFont.systemFont(ofSize: 24)
                // Add left padding to the checkmark label
                                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
                                paddingView.addSubview(checkmarkLabel)
                                cell.accessoryView = paddingView
                        } else {
                            cell.accessoryView = nil
                        }
            // Add spacing between the cell's text label and the checkmark
                        let spacing: CGFloat = 8.0
                        cell.textLabel?.frame.origin.x = spacing
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            dateFormatter.locale = Locale(identifier: "en_US")
            
            if let lastUpdatedDate = item.lastUpdate {
                let lastUpdatedDateString = dateFormatter.string(from: lastUpdatedDate)
                
                let dateLabel = UILabel()
                dateLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(dateLabel)
                
                dateLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
                dateLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20).isActive = true
                dateLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10).isActive = true
                
                dateLabel.text = "Last Updated on \(lastUpdatedDateString)"
                dateLabel.font = UIFont.italicSystemFont(ofSize: 12)

            } else {
                let creationDate = item.dateCreated
                let creationDateString = dateFormatter.string(from: creationDate)

                
                let creationDateLabel = UILabel()
                creationDateLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(creationDateLabel)
                
                creationDateLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
                creationDateLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20).isActive = true
                creationDateLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10).isActive = true
                
                creationDateLabel.text = "Saved on \(creationDateString)"
                creationDateLabel.font = UIFont.italicSystemFont(ofSize: 12)
                if let categoryColor = UIColor(hexString: selectedCategory?.colour ?? "") {
                                creationDateLabel.textColor = isColorDark(categoryColor) ? .white : .black
                            } else {
                                creationDateLabel.textColor = .white
                            }
                




                

            }
            
            // Configure the cell's appearance based on the category color
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
        } else {
            cell.textLabel?.text = "No Items Added"
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
            cell.textLabel?.textColor = .black
            cell.backgroundColor = UIColor(hexString: "79C0D0")
            cell.textLabel?.lineBreakMode = .byTruncatingTail // Truncate the text if no item is added
            cell.textLabel?.numberOfLines = 1 // Show only one line for the placeholder text
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
        if let item = todoItems?[indexPath.row] {
            let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = item.title // Set the initial text to the item's title
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                if let textField = alert.textFields?.first, let newText = textField.text, !newText.isEmpty {
                    // Perform the modifications within a write transaction
                    do {
                        let realm = try Realm()
                        try realm.write {
                            // Update the item's title
                            item.title = newText
                            
                            // Update the item's last updated date
                            item.lastUpdate = Date()
                            
                            // Update the item's created date to match the last updated date
                            if let lastUpdate = item.lastUpdate {
                                item.dateCreated = lastUpdate
                            }
                        }
                        
                        // Reload the table view to reflect the changes
                        self?.tableView.reloadData()
                    } catch {
                        print("Error updating item: \(error)")
                    }
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(updateAction)
            
            present(alert, animated: true, completion: nil)
        }
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
