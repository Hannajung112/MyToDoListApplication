//
//  Category.swift
//  MyTodoList
//
//  Created by Hanna Jung on 22/5/2564 BE.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    let items = List<Item>()
}
