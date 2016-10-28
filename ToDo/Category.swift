//
//  Category.swift
//  ToDo
//
//  Created by Ryan Brashear on 10/25/16.
//  Copyright © 2016 Ryan Brashear. All rights reserved.
//

import UIKit

class Category: NSObject, NSCoding {
    var name: String = ""
    
    let nameKey = "name"
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: nameKey) as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: nameKey)
    }
    
    override init() {
        super.init()
    }
    
    init(_ name: String) {
        self.name = name
    }
}
