//
//  ImageViewController.swift
//  ToDo
//
//  Created by Ryan Brashear on 10/27/16.
//  Copyright © 2016 Ryan Brashear. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = TaskStore.shared.selectedImage {
            imageView.image = image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func close(_ sender: AnyObject) {
        TaskStore.shared.selectedImage = nil
        dismiss(animated: true, completion: nil)
    }

}
