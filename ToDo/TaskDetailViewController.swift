//
//  TaskDetailViewController.swift
//  ToDo
//
//  Created by Ryan Brashear on 10/24/16.
//  Copyright © 2016 Ryan Brashear. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class TaskDetailViewController: UIViewController {

    @IBOutlet weak var taskTitleField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var completionSwitch: UISwitch!
    
    @IBOutlet weak var prioritySelector: UISegmentedControl!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var gestureRecognizer: UITapGestureRecognizer!
    
    var task = Task()
    let pickerData = CategoryStore.shared.getCategories()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date().addingTimeInterval(1.0 * 60.0)
        self.categoryPicker.dataSource = self
        self.categoryPicker.delegate = self
        taskTitleField.text = task.title
        task.dueDate > datePicker.minimumDate! ? (datePicker.date = task.dueDate) : (datePicker.date = datePicker.minimumDate!)
        completionSwitch.isOn = task.complete
        categoryPicker.selectRow(task.category, inComponent: 0, animated: true)
        prioritySelector.selectedSegmentIndex = task.priority.rawValue
        
        if let image = task.image {
            imageView.image = image
            addGestureRecognizer()
        } else {
            imageView.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addGestureRecognizer() {
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    func viewImage() {
        if let image = imageView.image {
            TaskStore.shared.selectedImage = image
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageNavController")
            present(viewController, animated: true, completion: nil)
        }
    }

    fileprivate func showPicker(_ type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = type
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        task.title = taskTitleField.text!
        let selectedPickerRow = categoryPicker.selectedRow(inComponent: 0)
        task.category = selectedPickerRow
        task.dueDate = datePicker.date
        task.lastModified = Date()
        task.complete = completionSwitch.isOn
        let currentSelected = prioritySelector.selectedSegmentIndex
        task.priority = task.priority.returnCase(currentSelected)
        task.image = imageView.image
        
        let notification = UNMutableNotificationContent()
        notification.title = task.title
        notification.subtitle = ""
        notification.categoryIdentifier = "Alert"
        notification.sound = UNNotificationSound.default()
        notification.body = "TASK IS DUE"
        let notificationDate = task.dueDate.timeIntervalSinceNow
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: trigger)
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var returnValue = true
        if identifier == "saveTaskDetail" {
            taskTitleField.text != "" ? (returnValue = true) : (returnValue = false)
            if returnValue == false {
                let alert = UIAlertController(title: "Error", message: "You must enter a value for the task title!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)

            }
        }
        return returnValue
    }
    
    @IBAction func choosePhoto(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Picture", message: "Choose a picture type", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in self.showPicker(.camera) }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in self.showPicker(.photoLibrary) }))
        present(alert, animated: true, completion: nil)
    }
}

extension TaskDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

extension TaskDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) //close the image picker when the user clicks cancel
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil) //still want to close the picker even when picking an image
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage { //if we actually get an image back, do this
            let maxSize: CGFloat = 512
            let scale = maxSize / image.size.width
            let newHeight = image.size.height * scale
            
            UIGraphicsBeginImageContext(CGSize(width: maxSize, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: maxSize, height: newHeight))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            imageView.image = resizedImage
            
            imageView.isHidden = false
            
            if gestureRecognizer != nil {
                imageView.removeGestureRecognizer(gestureRecognizer)
            }
            
            addGestureRecognizer()
        }
    }
}

extension TaskDetailViewController: UNUserNotificationCenterDelegate {
    
}
