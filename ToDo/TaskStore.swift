//
//  ToDoStore.swift
//  ToDo
//
//  Created by Ryan Brashear on 10/24/16.
//  Copyright © 2016 Ryan Brashear. All rights reserved.
//

import UIKit

class TaskStore {
    
    static let shared = TaskStore()
    
    fileprivate var tasks: [[Task]] = []
    
    var selectedImage: UIImage?
    
    init() {
        let filePath = archiveFilePath()
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            tasks = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! [[Task]]
        } else {
            for _ in 1...CategoryStore.shared.getCategoryCount() {
                tasks.append([])
            }
            tasks[0] = [Task(title: "Example Task", dueDate: Date(), lastModified: Date(), priority: .high, category: 0, complete: false)]
            tasks[1] = [Task(title: "Example Task", dueDate: Date(), lastModified: Date(), priority: .high, category: 0, complete: false)]
            tasks[2] = [Task(title: "Example Task", dueDate: Date(), lastModified: Date(), priority: .high, category: 0, complete: false)]
            tasks[3] = [Task(title: "Example Task", dueDate: Date(), lastModified: Date(), priority: .high, category: 0, complete: false)]
            save()
        }
    }
    
    // MARK: - Public Functions
    func getTask(_ sectionIndex: Int, _ rowIndex: Int) -> Task {
        return tasks[sectionIndex][rowIndex]
    }
    
    func addNewSection() {
        tasks.append([])
    }
    
    func getAllTasks() -> [[Task]] {
        return tasks
    }
    
    func updateTask(_ task: Task, _ sectionIndex: Int, _ rowIndex: Int) {
        tasks[sectionIndex][rowIndex] = task
        save()
    }
    
    func addTask(_ task: Task) {
        tasks[task.category].insert(task, at: 0)
        save()
    }
    
    func deleteTask(_ sectionIndex: Int, _ rowIndex: Int) {
        tasks[sectionIndex].remove(at: rowIndex)
        save()
    }
    
    func getRowCount(_ sectionIndex: Int) -> Int {
        return tasks[sectionIndex].count
    }
    
    func getIncompleteTasks() -> [[Task]] {
        var returnArray = [[Task]]()
        for _ in 1...CategoryStore.shared.getCategoryCount() {
            returnArray.append([])
        }
        for section in 0...tasks.count - 1 {
            for row in 0..<tasks[section].count {
                if tasks[section][row].complete == false {
                    returnArray[section].insert(getTask(section, row), at: 0)
                }
            }
        }
        return returnArray
    }
    
    func removeSection(_ sectionIndex: Int) {
        tasks.remove(at: sectionIndex)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(tasks, toFile: archiveFilePath())
    }
    
    func sort(_ section: Int) {
        tasks[section].sort(by: { task1, task2 in
            return (task1.priority.rawValue) > (task2.priority.rawValue)})
    }
    
    // MARK: - Private Functions
    fileprivate func archiveFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first!
        let path = (documentsDirectory as NSString).appendingPathComponent("TaskStore.plist")
        return path
    }
}
