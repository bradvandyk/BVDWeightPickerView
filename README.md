# BVDWeightPickerView
WeightPicker View for iOS that combines a UIPickerView with UIToolbar as a single view

BVDWeightPickerView comes preconfigured with weight values 80lbs to 300lbs

# Example
<p><img src="Screenshots/Example.png" alt="example">
</p>

# Adding to View
```Swift
// make the view hidden by default
self.weightPicker.hidden = true

// add it as a subview
self.view.addSubview(self.weightPicker)

// add the automatic constraints
self.weightPicker.addConstraintsToSuperview(self.view)
```

# Show Weight Picker
```Swift
// show our picker
self.weightPicker.show { (weight) -> Void in
    // success block
    self.lblWeight.text = "My Weight: \(weight)"
}
```
