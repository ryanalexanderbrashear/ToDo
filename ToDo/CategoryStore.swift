//
//  CategoryStore.swift
//  ToDo
//
//  Created by Ryan Brashear on 10/25/16.
//  Copyright © 2016 Ryan Brashear. All rights reserved.
//

import UIKit

class CategoryStore {
    static let shared = CategoryStore()
    
    fileprivate var categories: [Category] = []
    init() {
        let filePath = archiveFilePath()
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            categories = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! [Category]
        } else {
            categories.append(Category("Home"))
            categories.append(Category("Work"))
            categories.append(Category("Shopping"))
            categories.append(Category("Other"))
            save()
        }
    }
    
    func addCategory(_ name: String) {
        categories.append(Category(name))
        save()
    }
    
    func removeCategory(_ index: Int) {
        categories.remove(at: index)
        save()
    }
    
    func getCategory(_ index: Int) -> String {
        return categories[index].name
    }
    
    func getCategoryCount() -> Int {
        return categories.count
    }
    
    func updateCategory(_ index: Int, _ newName: String) {
        categories[index].name = newName
        save()
    }
    
    func getCategories() -> [String] {
        var resultArray = [String]()
        if categories.count > 0 {
            for i in 0...categories.count - 1 {
                resultArray.append(categories[i].name)
            }
        }
        return resultArray
    }

    func save() {
        NSKeyedArchiver.archiveRootObject(categories, toFile: archiveFilePath())
    }
    
    fileprivate func archiveFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first!
        let path = (documentsDirectory as NSString).appendingPathComponent("CategoryStore.plist")
        return path
    }
}
