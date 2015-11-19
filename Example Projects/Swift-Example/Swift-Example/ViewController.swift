//
//  ViewController.swift
//  Swift-Example
//
//  Created by Bradley Van Dyk on 11/19/15.
//  Copyright © 2015 Bradley Van Dyk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var lblWeight: UILabel!
    @IBOutlet var weightPicker: BVDWeightPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // make the view hidden by default
        self.weightPicker.hidden = true
        // add it as a subview
        self.view.addSubview(self.weightPicker)
        // add the automatic constraints
        self.weightPicker.addConstraintsToSuperview(self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnClick(sender: AnyObject) {
        // show our picker
        self.weightPicker.show { (weight) -> Void in
            // success block
            self.lblWeight.text = "My Weight: \(weight)"
        }
    }
}

