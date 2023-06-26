//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ezagor on 19.06.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
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
        
        loadCategories()
        
//        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else{
            fatalError("Navigation controller does not exist.")}
        
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        if let category = categories?[indexPath.row]{
            
            cell.textLabel?.text = categories?[indexPath.row].name
            
            if let categoryColor = UIColor(hexString: category.colour) {
                    cell.backgroundColor = categoryColor
                cell.textLabel?.textColor = calculateContrastColor(forColor: categoryColor)
            } else {
                cell.backgroundColor = UIColor(hexString: "98EECC")
                cell.textLabel?.textColor = .black
            }
            
            
//            let startColor = UIColor(red: 152/255, green: 238/255, blue: 204/255, alpha: 1.0)
//                let maxItems = CGFloat(categories?.count ?? 1)
//                let percentage = CGFloat(indexPath.row) / maxItems
//                let endColor = startColor.darken(byPercentage: 0.3 + (0.4 * percentage)) // Adjust the darkening factor to achieve the desired effect
//
//                cell.backgroundColor = endColor
            
        }else{
            cell.textLabel?.text = "No Categories added yet"
                cell.backgroundColor = UIColor(hexString: "1D9BF6")
        }
        
        
        
        return cell
        
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
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
    
    func loadCategories(){
        
        categories = realm.objects(Category.self)
        
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
                if let newName = alertController.textFields?.first?.text?.capitalized,
                   let category = category {
                    do {
                        try self.realm.write {
                            category.name = newName
                        }
                    } catch {
                        print("Error updating category name: \(error)")
                    }
                    self.tableView.reloadData()
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
