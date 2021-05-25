//
//  CategoryController.swift
//  MyTodoList
//
//  Created by Hanna Jung on 22/5/2564 BE.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryController : SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        loadCategories()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        
        navBar.backgroundColor = UIColor(hexString: "FF7F81")
    }
    
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"
        
        
        if let category = categories?[indexPath.row] {
            
            guard let categoryColour = UIColor(hexString: category.color)  else {fatalError()}
            
            cell.backgroundColor = categoryColour
           
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
            
        
            
             
            
       
        return cell
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }


   
    
    //MARK: - data manupulation methods
    
    func saveCategories(category: Category) {
        
        //*************** SaveData to Realm ***************
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch  {
            print("Error saving category in saveCategories Methods : \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    func loadCategories()  {
        
        //*************** fetchData from Realm ***************
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    
    
    //MARK: - delete method from swipeController
    
    override func updateModel(at indexPath: IndexPath) {
            
            if let categoryCell = self.categories?[indexPath.row] {
            
                do{
                    try self.realm.write {
                            self.realm.delete(categoryCell)
                        }
                    } catch {
                        print("Error delete category")
                    }
       
                }
    }
    
    
    
    
    
    
    
    //MARK: - Add categories
    
    @IBAction func AddCategory(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
//            self.categories.append(newCategory)
            
            self.saveCategories(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
   
  
}




