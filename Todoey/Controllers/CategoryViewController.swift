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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
//        tableView.separatorStyle = .none

        
    }
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let randomColor = UIColor().randomFlat()
        
        if let category = categories?[indexPath.row]{
            
            cell.textLabel?.text = categories?[indexPath.row].name
            if let categoryColor = UIColor(hexString: category.colour) {
                    cell.backgroundColor = categoryColor
            } else {
                cell.backgroundColor = UIColor(hexString: "98EECC")
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
    
    
    //MARK: - Add New Categories
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let randomColor2 = UIColor().randomFlat()
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = randomColor2.toHexString() ?? ""

            
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        present(alert, animated: true,completion: nil)
        
    }
    
}
