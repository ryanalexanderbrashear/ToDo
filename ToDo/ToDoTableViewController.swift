//
//  ToDoTableViewController.swift
//  ToDo
//
//  Created by Ryan Brashear on 10/24/16.
//  Copyright © 2016 Ryan Brashear. All rights reserved.
//

import UIKit

class ToDoTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var showCompleted: UISwitch!
    
    //MARK: - Class Level Variables
    
    let searchController = UISearchController(searchResultsController: nil)
    var sectionHeaders = CategoryStore.shared.getCategories()
    var readyToEdit = true
    var filteredArray = [[Task]]()
    var incompleteTasks = TaskStore.shared.getIncompleteTasks()
    let defaults = UserDefaults.standard

    //MARK: - Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.showsVerticalScrollIndicator = true
        tableView.refreshControl = nil
        
        let completionSwitchState = defaults.data(forKey: "showCompletedSwitchState")
        if let completionSwitchState = completionSwitchState {
            showCompleted.isOn = (NSKeyedUnarchiver.unarchiveObject(with: completionSwitchState) as? Bool)!
        } else {
            showCompleted.isOn = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
        sectionHeaders = CategoryStore.shared.getCategories()
        incompleteTasks = TaskStore.shared.getIncompleteTasks()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let completionSwitchState = NSKeyedArchiver.archivedData(withRootObject: showCompleted.isOn)
        defaults.set(completionSwitchState, forKey: "showCompletedSwitchState")
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditTaskSegue" {
            let taskDetailVC = segue.destination as! TaskDetailViewController
            let tableCell = sender as! TaskTableViewCell
            taskDetailVC.task = tableCell.task
        }
    }
    
    //MARK: - TableView Data Source Functions
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Arial", size: 24)!
        header.textLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        header.contentView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        let bottomBorder = UIView(frame: CGRect(x: 0, y: 26, width: self.view.bounds.width, height: 2))
        bottomBorder.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        header.contentView.addSubview(bottomBorder)
        let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 2))
        topBorder.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        header.contentView.addSubview(topBorder)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredArray[section].count
        } else if showCompleted.isOn == false {
            return incompleteTasks[section].count
        } else {
            return TaskStore.shared.getRowCount(section)
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskTableViewCell.self)) as! TaskTableViewCell
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.setupCell(filteredArray[indexPath.section][indexPath.row])
        } else if showCompleted.isOn == false {
            cell.setupCell(incompleteTasks[indexPath.section][indexPath.row])
        } else {
            cell.setupCell(TaskStore.shared.getTask(indexPath.section, indexPath.row))
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            TaskStore.shared.deleteTask(indexPath.section, indexPath.row)
            incompleteTasks = TaskStore.shared.getIncompleteTasks()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } 
    }
    
    //MARK: - Search Bar Filter Functions
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        let allTasks = TaskStore.shared.getAllTasks()
        let incompleteTasks = self.incompleteTasks
        if showCompleted.isOn {
            filter(allTasks, searchText)
        } else {
            filter(incompleteTasks, searchText)
        }
        tableView.reloadData()
    }
    
    func filter(_ inputArray: [[Task]], _ searchText: String) {
        filteredArray = []
        for _ in 0...CategoryStore.shared.getCategoryCount() {
            filteredArray.append([])
        }
        for i in 0..<inputArray.count {
            let toAdd = inputArray[i].filter { task in
                return task.title.lowercased().contains(searchText.lowercased())
            }
            if toAdd.count > 0 {
                filteredArray[i] = toAdd
            }
        }
    }
        
    //MARK: - IBActions

    @IBAction func edit(_ sender: AnyObject) {
        if readyToEdit {
            self.isEditing = true
            readyToEdit = false
        } else {
            self.isEditing = false
            readyToEdit = true
        }
    }
    
    @IBAction func saveTaskDetail(_ segue: UIStoryboardSegue) {
        let taskDetailVC = segue.source as! TaskDetailViewController
        self.isEditing = false
        readyToEdit = true
        if let indexPath = tableView.indexPathForSelectedRow {
            if TaskStore.shared.getTask(indexPath.section, indexPath.row).category != indexPath.section {
                let placeholder = TaskStore.shared.getTask(indexPath.section, indexPath.row)
                TaskStore.shared.deleteTask(indexPath.section, indexPath.row)
                TaskStore.shared.addTask(placeholder)
            }
            tableView.reloadData()
            TaskStore.shared.sort(taskDetailVC.task.category)
        } else {
            TaskStore.shared.addTask(taskDetailVC.task)
            tableView.reloadData()
            TaskStore.shared.sort(taskDetailVC.task.category)
        }
    }
    
    @IBAction func completionSwitchChanged(_ sender: AnyObject) {
        tableView.reloadData()
    }
    
}

//MARK: - UISearchResultsUpdating Extension

extension ToDoTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
