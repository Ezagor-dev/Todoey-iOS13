//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ezagor on 19.06.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: SwipeTableViewController, UISearchBarDelegate{
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    private var tableHeaderView: UIView!
        private var searchController: UISearchController!
    let realm = try! Realm()
    var selectedCategory: Category?
    
    var categories: Results<Category>?
    var pinnedCategories: Results<Category>?
    var unpinnedCategories: Results<Category>?
    
    let colorPalette: [UIColor] = [
        UIColor(hexString: "98EECC")!,
        UIColor(hexString: "D0F5BE")!,
        UIColor(hexString: "FBFFDC")!,
        UIColor(hexString: "A4907C")!,
        UIColor(hexString: "164B60")!,
        UIColor(hexString: "1B6B93")!,
        UIColor(hexString: "4FC0D0")!,
        UIColor(hexString: "A2FF86")!,
        UIColor(hexString: "2D4356")!,
        UIColor(hexString: "435B66")!,
        UIColor(hexString: "A76F6F")!,
        UIColor(hexString: "EAB2A0")!,
        UIColor(hexString: "525FE1")!,
        UIColor(hexString: "F86F03")!,
        UIColor(hexString: "FFA41B")!,
        UIColor(hexString: "FFF6F4")!,
        UIColor(hexString: "F1C27B")!,
        UIColor(hexString: "FFD89C")!,
        UIColor(hexString: "A2CDB0")!,
        UIColor(hexString: "85A389")!,
        UIColor(hexString: "A0C49D")!,
        UIColor(hexString: "C4D7B2")!,
        UIColor(hexString: "E1ECC8")!,
        UIColor(hexString: "F7FFE5")!,
        UIColor(hexString: "22A699")!,
        UIColor(hexString: "F2BE22")!,
        UIColor(hexString: "F29727")!,
        UIColor(hexString: "606C5D")!,
        UIColor(hexString: "FFF4F4")!,
        UIColor(hexString: "F7E6C4")!,
        UIColor(hexString: "F1C376")!,
        UIColor(hexString: "9AC5F4")!,
        UIColor(hexString: "99DBF5")!,
        UIColor(hexString: "A7ECEE")!,
        UIColor(hexString: "FFEEBB")!,
        UIColor(hexString: "79E0EE")!,
        UIColor(hexString: "98EECC")!,
        // Add more colors to the palette as desired
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .black
        
        loadCategories()
        setupTableHeaderView()
        
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
    //MARK: - Setup Methods
        
        private func setupTableHeaderView() {
            // Create a custom table view header view
            tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            tableHeaderView.backgroundColor = .clear
            
            // Create the search bar
            let searchBar = UISearchBar(frame: tableHeaderView.bounds)
            searchBar.delegate = self
            searchBar.placeholder = "Search Categories"
            searchBar.searchBarStyle = .minimal
            searchBar.autocapitalizationType = .none
            searchBar.searchTextField.textColor = .white
            
            // Add the search bar to the table view header view
            tableHeaderView.addSubview(searchBar)
            
            // Set the table view's tableHeaderView
            tableView.tableHeaderView = tableHeaderView
        }
    
    //MARK: - Search Bar Delegate Methods
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            // Dismiss the keyboard
            searchBar.resignFirstResponder()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // Perform the search operation
            filterCategories(with: searchText)
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            // Clear the search text and reload the original categories
            searchBar.text = nil
            filterCategories(with: "")
            searchBar.resignFirstResponder()
        }
        
        //MARK: - Helper Methods
        
        func filterCategories(with searchText: String) {
            // Update the categories based on the search text
            if searchText.isEmpty {
                // If the search text is empty, show all categories
                categories = realm.objects(Category.self).sorted(byKeyPath: "isPinned", ascending: false)
            } else {
                // Filter the categories based on the search text
                categories = realm.objects(Category.self).filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "isPinned", ascending: false)
            }
            
            tableView.reloadData()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the background color of the navigation bar to black
        navigationController?.navigationBar.barTintColor = .black
        
        // Set the title color to white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // Reset the category color to black in case it was set previously
        if let navBar = navigationController?.navigationBar {
            let categoryColor = UIColor(hexString: selectedCategory?.colour ?? "")
            navBar.backgroundColor = .black
            navBar.tintColor = .white
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            
            categoryColor?.withAlphaComponent(1.0)
            
        }
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        
        // Set the background color of the navigation bar to black
        navBar.barTintColor = .black
        
        // Set the title color to white
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    
    
    
    
    
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let minHeight: CGFloat = 80
        let defaultHeight: CGFloat = 44
        
        if let category = categories?[indexPath.row] {
            let text = category.name
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
        
        // Add spacing between rows
        let space: CGFloat = 10.0
        let inset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        cell.frame = cell.frame.inset(by: inset)
        // Set the corner radius of the cell's content view
        cell.contentView.layer.cornerRadius = cell.contentView.frame.height / 2
        
        
        // Add a border to the cell's content view
        cell.contentView.layer.borderWidth = 1.0
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            // Display the creation date in the creation date label
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            let creationDate = category.createdDate
            let creationDateString = dateFormatter.string(from: creationDate)

            creationDateLabel.text = "Created on \(creationDateString)"
                    
                    // Customize the appearance of the creation date label
                    creationDateLabel.font = UIFont.italicSystemFont(ofSize: 12)
                    creationDateLabel.textColor = UIColor.gray
            let completedItems = category.items.filter("done == true")
            let totalCount = category.items.count
            let completedCount = completedItems.count
            
            if let categoryColor = UIColor(hexString: category.colour) {
                // Set the border color of the cell's content view to the category color
                cell.contentView.layer.borderColor = categoryColor.cgColor
                cell.contentView.layer.backgroundColor = categoryColor.cgColor
                cell.textLabel?.textColor = calculateContrastColor(forColor: categoryColor)
                // Update label's properties
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.textLabel?.preferredMaxLayoutWidth = tableView.bounds.width - 20
                
                // Adjust cell's height based on text length
                let font = UIFont.systemFont(ofSize: 17)
                let text = category.name
                let textHeight = text.boundingRect(with: CGSize(width: tableView.bounds.width - 20, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
                let minHeight: CGFloat = 44
                let cellHeight = max(minHeight, textHeight + 20)
                cell.frame.size.height = cellHeight
            } else {
                // Set a default border color if the category color is invalid
                cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
                cell.textLabel?.textColor = .black
            }
        } else {
            cell.textLabel?.text = "No Categories added yet"
            cell.detailTextLabel?.text = ""
            cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
            cell.textLabel?.textColor = .black
            cell.textLabel?.lineBreakMode = .byTruncatingTail // Truncate the text if no item is added
            cell.textLabel?.numberOfLines = 1 // Show only one line for the placeholder text
            creationDateLabel.text = ""
        }
        
        // Set the background color of the cell
        cell.backgroundColor = .black
        
        return cell
    }
    
    
    
    
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = .black
            cell.selectedBackgroundView = selectedBackgroundView
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let selectedCategory = categories?[indexPath.row]
            let destinationVC = segue.destination as! ToDoListViewController
            destinationVC.selectedCategory = selectedCategory
        }
    }
    
    
    
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self).sorted(byKeyPath: "isPinned", ascending: false)
        tableView.reloadData()
    }
    
    
    
    
    
    
    
    
    
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        
        if let categoryForDeletion = self.categories?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error deleting category, \(error)")
            }
        }
    }
    
    //MARK: - Pin Data
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updateModel(at: indexPath)
        }
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            self.editModel(at: indexPath)
        }
        
        let pinActionTitle = categories?[indexPath.row].isPinned == true ? "Unpin" : "Pin"
            let pinAction = SwipeAction(style: .default, title: pinActionTitle) { action, indexPath in
                self.pinCategory(at: indexPath)
            }
        
        
        
        
        // Customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        editAction.image = UIImage(systemName: "pencil")
        pinAction.image = UIImage(systemName: "pin.fill")
        
        editAction.backgroundColor = .blue
        pinAction.backgroundColor = .gray
        
        return [deleteAction, editAction, pinAction]
    }
    
    func pinCategory(at indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            do {
                try realm.write {
                    category.isPinned = !category.isPinned
                    
                    let allCategories = realm.objects(Category.self).sorted(byKeyPath: "isPinned", ascending: false)
                    let pinnedCategories = allCategories.filter("isPinned == true")
                    let unpinnedCategories = allCategories.filter("isPinned == false")
                    
                    let concatenatedCategories = Array(pinnedCategories) + Array(unpinnedCategories)
                    categories = realm.objects(Category.self).filter("FALSEPREDICATE")
                    categories = realm.objects(Category.self).sorted(byKeyPath: "isPinned", ascending: false)
                    
                    tableView.reloadData()
                }
            } catch {
                print("Error updating category pin status, \(error)")
            }
        }
    }
    
    
    
    //MARK: - Edit Data From Swipe
    
    override func editModel(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Category", message: "", preferredStyle: .alert)
        let category = categories?[indexPath.row]
        
        alertController.addTextField { (textField) in
            textField.text = category?.name
            textField.autocapitalizationType = .words
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            if let newName = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
               !newName.isEmpty, let category = category {
                do {
                    try self.realm.write {
                        category.name = newName.capitalized
                    }
                } catch {
                    print("Error updating category name: \(error)")
                }
                self.tableView.reloadData()
            } else {
                // Show an error message indicating that the name cannot be empty
                let errorAlert = UIAlertController(title: "Error", message: "Category name cannot be empty.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                errorAlert.addAction(okAction)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - Add New Categories
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let categoryName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let name = categoryName, !name.isEmpty {
                let randomColor = UIColor().randomFlat()
                let newCategory = Category()
                newCategory.name = name.capitalized
                newCategory.colour = randomColor.toHexString() ?? ""
                
                self.save(category: newCategory)
            }else{
                let errorAlert = UIAlertController(title: "Error", message: "Category name cannot be empty.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                errorAlert.addAction(okAction)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
            textField.autocapitalizationType = .words
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
}
extension UILabel {
    func calculateMaxLines(width: CGFloat) -> Int {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let text = self.text ?? ""
        let font = self.font
        let attributes: [NSAttributedString.Key: Any] = [.font: font as Any]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textStorage = NSTextStorage(attributedString: attributedText)
        let textContainer = NSTextContainer(size: maxSize)
        let layoutManager = NSLayoutManager()
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        
        let numberOfGlyphs = textStorage.length
        let range = NSRange(location: 0, length: numberOfGlyphs)
        var numberOfLines = 0
        var index = 0
        var lineRange = NSRange()
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        
        return numberOfLines
    }
}
extension UITableView {
    func deselectSelectedRow(animated: Bool) {
        if let indexPath = indexPathForSelectedRow {
            deselectRow(at: indexPath, animated: animated)
        }
    }
}
