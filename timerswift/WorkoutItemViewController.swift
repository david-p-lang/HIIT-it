import UIKit

class WorkoutItemViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 0
    }
    
    
    var itemKey = "-"
    var itemValue = "60"
    var intSeconds = 0
    var intMinutes = 0
    var seconds = "1"
    var minutes = "0"
    var theTransferValues:NSArray!
    var theTransferKeys:NSArray!
    var newTransferValues:NSArray!
    var newTransferKeys:NSArray!
    var displayMinuteTime = "00:"
    var displaySecondsTime = "00"
    var theWorkoutManager:Workout = Workout()
    var theRelevantWorkoutName = ""
    var alertMessage = ""
    
    var imageViewHolder:UIImageView!
    var rootDictionary:NSMutableDictionary!
    
    var defaults = UserDefaults.standard
    var spinnerSeconds:NSMutableArray = []
    var spinnerMinutes:NSMutableArray = []
    
    var itemLabel: UILabel!
    var itemText: UILabel!
    var pickerView: UIPickerView!
    var spinnerBackView: UIView!
    var itemEdit: UITextField!
    var vStack: UIStackView!
    
    fileprivate func stackConfiguration() {
        vStack = UIStackView(frame: view.frame)
        vStack.alignment = .fill
        vStack.distribution = .fillEqually
        vStack.axis = .vertical
        vStack.backgroundColor = .red
        
        view.addSubview(vStack)
    }
    
    fileprivate func stackContraints() {
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        vStack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vStack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    fileprivate func itemLabelConfiguration() {
        itemLabel = UILabel()
        itemLabel.backgroundColor = .orange
        itemLabel.text = itemKey
        vStack.addArrangedSubview(itemLabel)

    }
    
    fileprivate func itemLabelConstraints() {
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.trailingAnchor.constraint(equalTo: vStack.trailingAnchor).isActive = true
        itemLabel.leadingAnchor.constraint(equalTo: vStack.leadingAnchor).isActive = true

    }
    
    fileprivate func itemTextConfiguration() {
        itemText = UILabel()
        itemText.backgroundColor = .magenta
        itemText.text = "--replace--"
        vStack.addArrangedSubview(itemText)
    }
    
    fileprivate func itemTextConstraints() {
        itemText.translatesAutoresizingMaskIntoConstraints = false
        itemText.trailingAnchor.constraint(equalTo: vStack.trailingAnchor).isActive = true
        itemText.leadingAnchor.constraint(equalTo: vStack.leadingAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        stackConfiguration()
        stackContraints()
        itemLabelConfiguration()
        itemLabelConstraints()
        itemTextConfiguration()
        itemTextConstraints()
        
        
        pickerView = UIPickerView()
        spinnerBackView = UIView()
        itemEdit = UITextField()
        
        itemLabel.text = itemKey
        print("itemkey is " + itemKey)
        
        
        for i in 0...59 {
            self.spinnerSeconds[i] = "\(i)"
        }
        for i in 0...9 {
            self.spinnerMinutes[i] = i.description
        }
        
        if itemKey == "Rest Time" || itemKey == "Warmup Time" || itemKey == "Cooldown Time" {
            displayInitTime()
            pickerView.isHidden = false
            spinnerBackView.isHidden = false
            itemText.isHidden = false
        } else {
            itemText.text = itemValue
            itemEdit.isHidden = false
            itemEdit.keyboardType = UIKeyboardType.numberPad
        }
        
        // Do any additional setup after loading the view.
    }
    func displayInitTime () {
        displayMinuteTime = String(Int(itemValue)! / 60) + ":"
        if Int(itemValue)! % 60 < 10 {
            displaySecondsTime = "0" + String(Int(itemValue)! % 60)
        } else {
            displaySecondsTime = "0" + String(Int(itemValue)! % 60)
        }
        itemText.text = displayMinuteTime + displaySecondsTime
        
    }
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //==================================SAVE========================================
    @IBAction func saveItem(sender: AnyObject) {
        
        itemEdit.resignFirstResponder()
        let totSecs = ((intMinutes * 60) + intSeconds)
        
        if itemKey == "Interval Count" {
            print("itemkey is " + itemKey)
            if Int(itemEdit.text!) != nil {
                theWorkoutManager.intervalCount = Int(itemEdit.text!)!
            } else {
                alertMessage = "Enter a number of intervals"
                print(alertMessage)
            }
        }
        if itemKey == "Heart Rate Goal" {
            if (itemEdit.text!) != "" {
                theWorkoutManager.heartRateGoal = Int(itemEdit.text!)!
            } else {
                alertMessage = "Enter a numeric heart rate goal"
            }
        }
        if itemKey == "Rest Time"  {
            theWorkoutManager.restTime = totSecs
        }
        if itemKey == "Warmup Time" {
            theWorkoutManager.warmupTime = totSecs
        }
        if itemKey == "Cooldown Time" {
            theWorkoutManager.cooldownTime = totSecs
        }
        
        print(theWorkoutManager.getWorkoutPlan())
        theWorkoutManager.saveWorkoutItems()
        performSegue(withIdentifier: "savedItemSegue", sender: self)
        
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print("segue call")
        if segue.identifier == "savedItemSegue" {
            var vc = segue.destination as! ViewController
            vc.theWorkout = Workout()
            vc.imageView = imageViewHolder
            vc.sideBarDidSelectButtonAtIndex(index: 1)
        }
    }*/
    //============================HANDLEKEYBOARD===========================
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return spinnerMinutes.count
        } else {
            return spinnerSeconds.count
        }
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) -> Int {
        if component == 0 {
            intMinutes = row
            minutes = spinnerMinutes[row] as! String
            displayMinuteTime = minutes + ":"
            itemText.text = displayMinuteTime + displaySecondsTime
        } else {
            intSeconds = row
            seconds = spinnerSeconds[row] as! String
            if row < 10 {
                displaySecondsTime = "0" + seconds
            } else {
                displaySecondsTime = seconds
            }
            itemText.text = displayMinuteTime + displaySecondsTime
        }
        return component
        
    }
    private func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if component == 0 {
            return String(spinnerMinutes[row] as! NSString)
            
        } else {
            return String(spinnerSeconds[row] as! NSString)
        }
    }
    
    
    
}
