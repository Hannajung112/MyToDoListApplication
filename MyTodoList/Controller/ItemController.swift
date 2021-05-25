//
//  ViewController.swift
//  MyTodoList
//
//  Created by Hanna Jung on 22/5/2564 BE.
//

import UIKit
import RealmSwift
import ChameleonFramework


class ItemController : SwipeTableViewController {
    
    let realm = try! Realm()
    
    var toDoItems : Results<Item>?
    
    var selectedCategory : Category? {
        didSet {
            loadItems() 
        }
    }

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
    }
    
        
        override func viewWillAppear(_ animated: Bool) {
            
            if let colourHex = selectedCategory?.color {
                title = selectedCategory!.name
                guard let navBar = navigationController?.navigationBar else {
                    fatalError("Navigation controller does not exist.")
                }
                if let navBarColour = UIColor(hexString: colourHex) {
                    navBar.backgroundColor = navBarColour
                    navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                    searchBar.barTintColor = navBarColour
                }
            }
        }

    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            let index = CGFloat(indexPath.row)
            let items = CGFloat(toDoItems!.count)
            
            let result = index / items
            
            
            if let colour = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: result) {
                
                cell.backgroundColor = colour
                
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            
            
            cell.accessoryType = item.done ? .checkmark : .none
        
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell

    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch  {
                print("Error saving done status : \(error)")
            }
            
        }
        
        tableView.reloadData()
    }
    
    
    
    //MARK: - Data manupulation methods
    
//    func saveItems(item : Item)  {
//        do {
//            try realm.write{
//                realm.add(item)
//            }
//        } catch  {
//            print("Error saving item in saveItems Methods : \(error)")
//        }
//
//        tableView.reloadData()
//    }
//
    
    func loadItems()  {
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    
    
    
    //MARK: - Delete method from SwipeController
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemTodoList = toDoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemTodoList)
                }
            } catch  {
                print("Error acording to itemTodoList delete method: \(error)")
            }
        }
        
    }
    
    
    
    //MARK: - Add Items

    @IBAction func Additem(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch  {
                    print("Error saving item : \(error)")
                }
                
            }
            
            self.tableView.reloadData()
        }
            
            alert.addAction(action)
        
            alert.addTextField { (field) in
                textField = field
                textField.placeholder = "Add new item"
            }
        
            present(alert, animated: true, completion: nil)
        
        
    
            
            
        }
        
}


//MARK: - SearchBar

extension ItemController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
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



