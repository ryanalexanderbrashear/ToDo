//
//  CategoryDetailViewController.swift
//  ToDo
//
//  Created by Ryan Brashear on 10/27/16.
//  Copyright © 2016 Ryan Brashear. All rights reserved.
//

import UIKit

class CategoryDetailViewController: UIViewController {
    
    @IBOutlet weak var categoryName: UITextField!
    
    var category = Category()

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryName.text = category.name
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        category.name = categoryName.text!
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var returnValue = true
        if identifier == "saveCategoryDetail" {
            categoryName.text != "" ? (returnValue = true) : (returnValue = false)
            if returnValue == false {
                let alert = UIAlertController(title: "Error", message: "You must enter a value for the category name!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        return returnValue
    }


}
