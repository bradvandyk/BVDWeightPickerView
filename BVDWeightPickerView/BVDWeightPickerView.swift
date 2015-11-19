//
//  BVDWeightPickerView
//  tdee
//
//  Created by Bradley Van Dyk on 11/15/15.
//  Copyright © 2015 Bradley Van Dyk. All rights reserved.
//

import UIKit


@IBDesignable class BVDWeightPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Variables
    
    // Our custom view from the XIB file
    var view: UIView!
    var blackoutView:UIView? = nil
    var saveClosure: ((weight:Double)->Void)?
    let LAST_WEIGHT_ENTRY_KEY = "lastWeightEntry"
    var bottomLayoutConstraint:NSLayoutConstraint? = nil
    
    // Outlets
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    // MARK: View Overrides / Setup
    override func removeFromSuperview() {
        self.blackoutView?.removeFromSuperview()
        super.removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.setupData()
    }
    
    private func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "BVDWeightPickerView", bundle: bundle)
        
        // Assumes UIView is top level and only object in BVDWeightPickerView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func btnCancelClick(sender: UIBarButtonItem) {
        hide()
    }
    
    @IBAction func btnSaveClick(sender: UIBarButtonItem) {
        if let weight = Double(self.pickerData[0][self.pickerView.selectedRowInComponent(0)]) {
            if let tenthWeight = Double(self.pickerData[1][self.pickerView.selectedRowInComponent(1)]) {
                let extractedWeight = weight + tenthWeight
                self.saveClosure?(weight: extractedWeight)
                
                NSUserDefaults.standardUserDefaults().setDouble(extractedWeight, forKey: LAST_WEIGHT_ENTRY_KEY)
                hide()
            }
        }
    }
    
    // MARK: Helper
    
    func stringWithoutZeroDot(value:Double) -> String {
        let tenthString = String(value)
        let index:String.Index = tenthString.startIndex.advancedBy(1)
        let stringWithoutZeroDot = tenthString.substringFromIndex(index) // remove 0. so string just displays .1
        
        return stringWithoutZeroDot
    }
    
    func addBlackout() {
        if self.blackoutView == nil {
            // add the blackout screen to the superview
            if let superview = self.superview {
                self.blackoutView = UIView(frame: CGRectMake(0, 0, 100, 100))
                self.blackoutView?.backgroundColor = UIColor.blackColor()
                self.blackoutView?.alpha = 0.5
                superview.addSubview(self.blackoutView!)
                self.blackoutView?.hidden = true
                
                self.blackoutView?.translatesAutoresizingMaskIntoConstraints = false
                
                let expandToRightConstraint = NSLayoutConstraint(item: self.blackoutView!,
                    attribute: NSLayoutAttribute.RightMargin,
                    relatedBy: .Equal,
                    toItem: superview,
                    attribute: NSLayoutAttribute.RightMargin,
                    multiplier: 1.0,
                    constant: 20)
                let expandToLeftConstraint = NSLayoutConstraint(item: self.blackoutView!,
                    attribute: NSLayoutAttribute.LeftMargin,
                    relatedBy: .Equal,
                    toItem: superview,
                    attribute: NSLayoutAttribute.LeftMargin,
                    multiplier: 1.0,
                    constant: -20)
                let expandToTopConstraint = NSLayoutConstraint(item: self.blackoutView!,
                    attribute: NSLayoutAttribute.TopMargin,
                    relatedBy: .Equal,
                    toItem: superview,
                    attribute: NSLayoutAttribute.TopMargin,
                    multiplier: 1.0,
                    constant: 0)
                
                let expandToBottomConstraint = NSLayoutConstraint(item: self.blackoutView!,
                    attribute: NSLayoutAttribute.BottomMargin,
                    relatedBy: .Equal,
                    toItem: self,
                    attribute: NSLayoutAttribute.TopMargin,
                    multiplier: 1.0,
                    constant: -15)
                
                superview.addConstraint(expandToRightConstraint)
                superview.addConstraint(expandToLeftConstraint)
                superview.addConstraint(expandToTopConstraint)
                superview.addConstraint(expandToBottomConstraint)
            }
        }
    }
    
    // MARK: Public
    func show(onComplete: (weight:Double)->Void) {
        addBlackout()   // add blackout if we don't have one already
        self.saveClosure = onComplete
        
        // make sure everything is shown
        self.hidden = false
        self.blackoutView?.hidden = false
        self.alpha = 0
        self.blackoutView?.alpha = 0
        
        self.superview!.layoutIfNeeded()
        UIView.animateWithDuration(0.3) { () -> Void in
            self.bottomLayoutConstraint?.constant = 0
            self.superview!.layoutIfNeeded()
            self.blackoutView?.alpha = 0.5
            self.alpha = 1
        }
    }
    
    func hide() {
        self.superview!.layoutIfNeeded()
        UIView.animateWithDuration(0.3) { () -> Void in
            self.bottomLayoutConstraint?.constant = self.frame.size.height
            self.superview!.layoutIfNeeded()
            self.blackoutView?.alpha = 0
            self.alpha = 0
        }
    }
    
    func addConstraintsToSuperview(superview: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint1 = NSLayoutConstraint(item: self,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: superview,
            attribute: .Width,
            multiplier: 1,
            constant: 0)
        let constraint2 = NSLayoutConstraint(item: self,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: .Equal,
            toItem: superview,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
        self.bottomLayoutConstraint = NSLayoutConstraint(item: self,
            attribute: NSLayoutAttribute.BottomMargin,
            relatedBy: .Equal,
            toItem: superview,
            attribute: NSLayoutAttribute.BottomMargin,
            multiplier: 1,
            constant: self.frame.size.height)
        
        superview.addConstraint(constraint1)
        superview.addConstraint(constraint2)
        superview.addConstraint(self.bottomLayoutConstraint!)
    }
    
    // MARK: PickerView DataSource / Delegate

    var pickerData = [[String]]()
    
    func setupData() {
        pickerData.append([String]())
        for i in 80...300 {
            pickerData[0].append(String(i))
        }
        
        pickerData.append([String]())
        pickerData[1].append("0")
        for i in 1...9 {
            let tenth:Double = Double(i) / 10.0
            let stringWithoutZeroDot = self.stringWithoutZeroDot(tenth)
            
            pickerData[1].append(stringWithoutZeroDot)
        }
        
        var defaultSelectedRow = 120 // this should give us around 200lbs
        var defaultSelectedRowDecimal = 0 // this should give us .0
        
        let lastWeightEntry = NSUserDefaults.standardUserDefaults().doubleForKey(LAST_WEIGHT_ENTRY_KEY)
        if (lastWeightEntry != 0) {
            // extract the decimal part of the last weight entry
            let numberOfPlaces:Double = 4.0
            let powerOfTen:Double = pow(10.0, numberOfPlaces)
            
            let weightDecimal:Double = round((lastWeightEntry % 1.0) * powerOfTen) / powerOfTen
            let weight:Double = lastWeightEntry - weightDecimal
            
            // extract indexes based on weight and weightDecimal
            if let extractedIndex = self.pickerData[0].indexOf(String(Int(weight))) {
                defaultSelectedRow = extractedIndex
            }
            if let extractedIndex = self.pickerData[1].indexOf(self.stringWithoutZeroDot(weightDecimal)) {
                defaultSelectedRowDecimal = extractedIndex
            }
        }
        
        // set default selection
        self.pickerView.selectRow(defaultSelectedRow, inComponent: 0, animated: false)
        self.pickerView.selectRow(defaultSelectedRowDecimal, inComponent: 1, animated: false)
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count + 1 // add one for "lbs"
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 2) {
            return 1
        }
        
        return pickerData[component].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 2) {
            return "lbs"
        }
        
        return String(pickerData[component][row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        myLabel.text = "str" + String(row)
    }
}