//
//  TaskTableViewCell.swift
//  ToDo
//
//  Created by Ryan Brashear on 10/24/16.
//  Copyright © 2016 Ryan Brashear. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskDueDateLabel: UILabel!
    @IBOutlet weak var taskPriorityLabel: UILabel!
    @IBOutlet weak var taskLastModifiedLabel: UILabel!
    @IBOutlet weak var taskIsCompleteSwitch: UISegmentedControl!
    
    weak var task: Task!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(_ task: Task) {
        self.task = task
        taskTitleLabel.text = task.title
        taskDueDateLabel.text = task.dueDateString
        if task.dueDate.compare(Date()) == .orderedAscending {
            taskDueDateLabel.textColor = #colorLiteral(red: 1, green: 0.1891451776, blue: 0.2564486861, alpha: 1)
        } else {
            taskDueDateLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        taskLastModifiedLabel.text = task.lastModifiedString
        task.complete == true ? (taskIsCompleteSwitch.selectedSegmentIndex = 0) : (taskIsCompleteSwitch.selectedSegmentIndex = 1)
        task.priority == .high ? (taskPriorityLabel.backgroundColor = #colorLiteral(red: 1, green: 0.1891451776, blue: 0.2564486861, alpha: 1)) : task.priority == .medium ? (taskPriorityLabel.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)) : (taskPriorityLabel.backgroundColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1))
        
    }

}


