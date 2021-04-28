//
//  HomeViewController.swift
//  PetFeeder
//
//  Created by Javier Gonzalez on 3/20/21.
//

import UIKit
import Firebase
import FirebaseDatabase


class HomeViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var signOutButton: UIButton!
	@IBOutlet weak var dispenseButton: UIButton!
	@IBOutlet weak var feedDurationLabel: UILabel!
	@IBOutlet weak var feedDurationVal: UILabel!
	@IBOutlet weak var feedDurationSlider: UISlider!
	@IBOutlet weak var currentBowlWeightLabel: UILabel!
	@IBOutlet weak var bowlWeightLabel: UILabel!
	@IBOutlet weak var tareButton: UIButton!
	@IBOutlet weak var minBowlWeightLabel: UILabel!
	@IBOutlet weak var minBowlWeightVal: UILabel!
	@IBOutlet weak var minBowlWeightSlider: UISlider!
	@IBOutlet weak var scheduleOneLabel: UILabel!
	@IBOutlet weak var scheduleTwoLabel: UILabel!
	@IBOutlet weak var scheduleOneTextField: UITextField!
	@IBOutlet weak var scheduleTwoTextField: UITextField!
	@IBOutlet weak var updateButton: UIButton!
	@IBOutlet weak var sunButton: UIButton!
	@IBOutlet weak var monButton: UIButton!
	@IBOutlet weak var tueButton: UIButton!
	@IBOutlet weak var wedButton: UIButton!
	@IBOutlet weak var thuButton: UIButton!
	@IBOutlet weak var friButton: UIButton!
	@IBOutlet weak var satButton: UIButton!
	@IBOutlet weak var schedulingHStackView: UIStackView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var mainVStackView: UIStackView!
	@IBOutlet weak var mainStackViewTopConstraint: NSLayoutConstraint!
	let mainVStackViewTopConstraint:CGFloat = -9;
	var timePickerView = UIPickerView()
	var dayOfWeekButtons = Array<UIButton>()
	
	var fromSignUp = false
	var dispense = 0
	var tare = 0
	var feedDuration = 0
	var currentBowlWeight = 0
	var minimumBowlWeight = 0
	var scheduleOne = ""
	var scheduleTwo = ""
	var daysOfWeek = 0b0000000
	//let hours = 0...23
	let hours = Array(0...23)
	let minutes = Array(0...59)
	var currentHour = 0
	var currentMinute = 0
	var currentHourTwo = 0
	var currentMinuteTwo = 0
	var soPressed = false
	var stPressed = false
	
	var lastClickedField : UITextField?
	
	//reference to the firebase database and userid
	let db = Database.database().reference()
	var userid = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		//get user data
		
		if !fromSignUp {
			self.getUserData()
		}
		//Set up Elements
		self.setUpElements()
		//Set up bowl weight observer
		observeCurrentBowlWeight()
		dayOfWeekButtons = [sunButton, monButton, tueButton, wedButton, thuButton, friButton, satButton]
		
//		//creates the timepicker and configures it
//		timePickerView.delegate = self
//		timePickerView.dataSource = self
//		scheduleOneTextField.inputView = timePickerView
//		scheduleOneTextField.textAlignment = .center
//		scheduleTwoTextField.inputView = timePickerView
//		scheduleTwoTextField.textAlignment = .center
		

//		// ToolBar
//		let toolBar = UIToolbar()
//		toolBar.barStyle = .default
//		toolBar.isTranslucent = true
//		toolBar.tintColor = UIColor(red: 50/255, green: 175/255, blue: 100/255, alpha: 1)
//		toolBar.sizeToFit()
//		// Adding Button ToolBar
//		let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
//		toolBar.setItems([doneButton], animated: false)
//		toolBar.isUserInteractionEnabled = true
//		//adds the toolbar to the scrollview of both textfields
//		scheduleOneTextField.inputAccessoryView = toolBar
//		scheduleTwoTextField.inputAccessoryView = toolBar
		
		//handles the keyboard showing and hiding adjustments
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}
    
	func setUpElements() {
		Utilities.styleFilledButtonDashboard(dispenseButton)
		Utilities.styleFilledButtonDashboard(tareButton)
		Utilities.styleFilledButton(signOutButton)
		Utilities.styleTextField(scheduleOneTextField)
		Utilities.styleTextField(scheduleTwoTextField)
		Utilities.styleFilledButton(updateButton)
		//sets the textfield delegates
		scheduleOneTextField.delegate = self
		scheduleTwoTextField.delegate = self
		//Sets the return key type
		scheduleOneTextField.returnKeyType = .done
		scheduleTwoTextField.returnKeyType = .done
		//sets up the schedule buttons
		Utilities.styleDayOfWeekButton(sunButton)
		Utilities.styleDayOfWeekButton(monButton)
		Utilities.styleDayOfWeekButton(tueButton)
		Utilities.styleDayOfWeekButton(wedButton)
		Utilities.styleDayOfWeekButton(thuButton)
		Utilities.styleDayOfWeekButton(friButton)
		Utilities.styleDayOfWeekButton(satButton)
		//creates the timepicker and configures it
		timePickerView.delegate = self
		timePickerView.dataSource = self
		scheduleOneTextField.inputView = timePickerView
		scheduleOneTextField.textAlignment = .center
		scheduleTwoTextField.inputView = timePickerView
		scheduleTwoTextField.textAlignment = .center
		// ToolBar
		let toolBar = UIToolbar()
		toolBar.barStyle = .default
		toolBar.isTranslucent = true
		toolBar.tintColor = UIColor(red: 50/255, green: 175/255, blue: 100/255, alpha: 1)
		toolBar.sizeToFit()
		// Adding Button ToolBar
		let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
		toolBar.setItems([doneButton], animated: false)
		toolBar.isUserInteractionEnabled = true
		//adds the toolbar to the scrollview of both textfields
		scheduleOneTextField.inputAccessoryView = toolBar
		scheduleTwoTextField.inputAccessoryView = toolBar
	}
	
	
	//handles the resigning of the scrollpicker
	@objc func doneClick() {
		scheduleOneTextField.resignFirstResponder()
		scheduleTwoTextField.resignFirstResponder()
		soPressed = false
		stPressed = false
	}
	
	@IBAction func sunButtonTouched(_ sender: Any) {
		//modify binary days value
		daysOfWeek ^= 0b1000000
		//change button appearance
		changeDayOfWeeksButton(sender as! UIButton)
	}
	@IBAction func monButtonTouched(_ sender: Any) {
		//modify binary days value
		daysOfWeek ^= 0b0100000
		//change button appearance
		changeDayOfWeeksButton(sender as! UIButton)
	}
	@IBAction func tueButtonTouched(_ sender: Any) {
		//modify binary days value
		daysOfWeek ^= 0b0010000
		//change button appearance
		changeDayOfWeeksButton(sender as! UIButton)
	}
	@IBAction func wedButtonTouched(_ sender: Any) {
		//modify binary days value
		daysOfWeek ^= 0b0001000
		//change button appearance
		changeDayOfWeeksButton(sender as! UIButton)
	}
	@IBAction func thuButtonTouched(_ sender: Any) {
		//modify binary days value
		daysOfWeek ^= 0b0000100
		//change button appearance
		changeDayOfWeeksButton(sender as! UIButton)
	}
	@IBAction func friButtonTouched(_ sender: Any) {
		//modify binary days value
		daysOfWeek ^= 0b0000010
		//change button appearance
		changeDayOfWeeksButton(sender as! UIButton)
	}
	@IBAction func satButtonTouched(_ sender: Any) {
		//modify binary days value
		daysOfWeek ^= 0b0000001
		//change button appearance
		changeDayOfWeeksButton(sender as! UIButton)
	}
	//handles actions when sign out is tapped
	@IBAction func signOutTapped(_ sender: Any) {
		//Sign out user
		let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
		alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (UIAlertAction) in
			self.signOutUser()
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func feedDurationSliderMoved(_ sender: Any) {
		//Update the feed duration label
		feedDurationVal.text = String(Int(feedDurationSlider.value))
	}
	
	@IBAction func minBowlWeightSliderMoved(_ sender: Any) {
		//Update min bowl weight label
		minBowlWeightVal.text = String(Int(minBowlWeightSlider.value))
		
	}
	//updates the value of dispense in the database
	@IBAction func dispenseFoodBtnPressed(_ sender: Any) {
		Utilities.animateButtonPress(dispenseButton)
		//Send one to the database dispense field
		guard let key = db.child("users").child(userid).child("feedinginfo").key else { return }
		let info = ["dispense": 1,
					"feedduration": self.feedDuration,
					"currentbowlweight": self.currentBowlWeight,
					"tarebowl": 0,
					"minbowlweight": self.minimumBowlWeight,
					"scheduleone":scheduleOne,
					"scheduletwo":scheduleTwo] as [String : Any]

		let childUpdates = ["/users/\(userid)/\(key)/": info]
		db.updateChildValues(childUpdates)
	}
	//updates the value of tare to 1 in the database
	@IBAction func tareBtnPressed(_ sender: Any) {
		Utilities.animateButtonPress(tareButton)
		//Send one to the database tare field
		guard let key = db.child("users").child(userid).child("feedinginfo").key else { return }
		let info = ["dispense": 0,
					"feedduration": self.feedDuration,
					"currentbowlweight": self.currentBowlWeight,
					"tarebowl": 1,
					"minbowlweight": self.minimumBowlWeight,
					"scheduleone":scheduleOne,
					"scheduletwo":scheduleTwo] as [String : Any]

		let childUpdates = ["/users/\(userid)/\(key)/": info]
		db.updateChildValues(childUpdates)
	}
	//handles adding scrollpicker values to schedule one TF
	@IBAction func scheduleOneEditted(_ sender: UITextField) {
		//dont think i need anything here
		lastClickedField = sender
	}
	//handles adding the scrollpicker value to schdule two TF
	@IBAction func scheduleTwoEditted(_ sender: UITextField) {
		//i dont think i need anything here
		lastClickedField = sender
	}
	//sends command to update database when button is pressed
	@IBAction func updateButtonPressed(_ sender: Any) {
		//update database with current values of sliders and date/time
		Utilities.animateButtonPress(updateButton)
		scheduleOne = String(String(format: "%02d", currentHour)+String(format: "%02d", currentMinute)+String(daysOfWeek))
		scheduleTwo = String(String(format: "%02d", currentHourTwo)+String(format: "%02d", currentMinuteTwo)+String(daysOfWeek))
		updateUserData()
	}
	//changes the look of the day of week buttons when pressed
	func changeDayOfWeeksButton(_ sender: UIButton) {
		let bg = UIColor.init(red: 50/255, green: 175/255, blue: 100/255, alpha: 0.6)
		if(sender.backgroundColor == bg) {
			//deselect and change stored value
			sender.backgroundColor = UIColor.clear
		} else {
			//select and change stored value
			sender.backgroundColor = bg
		}
	}
	//gets the database values and stores them locally
	func getUserData() {
		let userID = Auth.auth().currentUser?.uid
		userid = userID!
		db.child("users").child(userID!).child("feedinginfo").observeSingleEvent(of: .value, with: { [self] (snapshot) in
			// Get user value
			let value = snapshot.value as? NSDictionary
			let bowlweight = value?["currentbowlweight"] as? Int64 ?? 0
			let minbowlweight = value?["minbowlweight"] as? Int64 ?? 0
			//let tarebowl = value?["tarebowl"] as? Int64 ?? 0
			let feedduration = value?["feedduration"] as? Int64 ?? 0
			//let dispense = value?["dispense"] as? Int64 ?? 0
			let scheduleone = value?["scheduleone"] as? String ?? ""
			let scheduletwo = value?["scheduletwo"] as? String ?? ""
			
			self.currentBowlWeight = Int(bowlweight)
			self.minimumBowlWeight = Int(minbowlweight)
			self.tare = 0
			self.feedDuration = Int(feedduration)
			self.dispense = 0
			self.scheduleOne = scheduleone;
			self.scheduleTwo = scheduletwo;
			populateSchedule()
			bowlWeightLabel.text = String(bowlweight)
			feedDurationVal.text = String(feedduration)
			feedDurationSlider.value = Float(feedduration)
			minBowlWeightVal.text = String(minbowlweight)
			minBowlWeightSlider.value = Float(minbowlweight)
			}) { (error) in
			print(error.localizedDescription)
		}
	}
	//handles showing the correct schedule when the app is opened
	func populateSchedule() {
		//schedule one
		var start = scheduleOne.startIndex
		var end = scheduleOne.index(start, offsetBy: 1)
		var range = start...end
		var st = scheduleOne[range]
		currentHour = Int(st)!
		scheduleOneTextField.text = String(st)+":"
		start = scheduleOne.index(after: end)
		end = scheduleOne.index(start, offsetBy: 1)
		range = start...end
		currentMinute = Int(scheduleOne[range])!
		scheduleOneTextField.text?.append(contentsOf: scheduleOne[range])
		start = scheduleOne.index(after: end)
		end = scheduleOne.index(before: scheduleOne.endIndex)
		range = start...end
		daysOfWeek = Int(scheduleOne[range])!
		print(daysOfWeek)
		var temp = 0b1000000
		for b in dayOfWeekButtons {
			if (daysOfWeek&temp==temp) {
				//is set, change appearance
				print("day of week on\n")
				changeDayOfWeeksButton(b)
			}
			print("after checking" + String(temp))
			temp = temp >> 1
		}
		//schedule two
		start = scheduleTwo.startIndex
		end = scheduleTwo.index(start, offsetBy: 1)
		range = start...end
		st = scheduleTwo[range]
		currentHourTwo = Int(st)!
		scheduleTwoTextField.text = String(st)+":"
		start = scheduleTwo.index(after: end)
		end = scheduleTwo.index(start, offsetBy: 1)
		range = start...end
		currentMinuteTwo = Int(scheduleTwo[range])!
		scheduleTwoTextField.text?.append(contentsOf: scheduleTwo[range])
		start = scheduleTwo.index(after: end)
		end = scheduleTwo.index(before: scheduleTwo.endIndex)
		range = start...end
	}
	//sends local updated values to the database
	func updateUserData() {
		//update local variables
		feedDuration = Int(feedDurationSlider.value)
		currentBowlWeight = Int(bowlWeightLabel.text!)!
		minimumBowlWeight = Int(minBowlWeightSlider.value)


		guard let key = db.child("users").child(userid).child("feedinginfo").key else { return }
		let info = ["dispense": 0,
					"feedduration": Int(feedDurationSlider.value),
					"currentbowlweight": Int(bowlWeightLabel.text!)!,
					"tarebowl": 0,
					"minbowlweight": Int(minBowlWeightSlider.value),
					"scheduleone": scheduleOne,
					"scheduletwo": scheduleTwo] as [String : Any]
		let childUpdates = ["/users/\(userid)/\(key)/": info]
		db.updateChildValues(childUpdates)
	}
	//signs out the user and unwinds to the home screen
	func signOutUser() {
		do {
			try FirebaseAuth.Auth.auth().signOut()
			performSegue(withIdentifier: "unwindToOne", sender: self)
			print("signed out successfully")
		} catch {
			print("cant sign out")
		}
	}
	//adjusts the screen for the textfields to prevent overlapping
	@objc func keyboardWillChange(notification: NSNotification) {
		
		guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
			return
		}
		
		if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
			view.frame.origin.y = -keyboardRect.height
		} else {
			view.frame.origin.y = 0
		}

	}
	//resigns first responder for keyboard/scrollpicker
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	//observes changes in the current bowl weight
	func observeCurrentBowlWeight() {
		db.child("users").child(userid).child("feedinginfo/currentbowlweight").observe(.value) { (DataSnapshot) in
			let cbw = DataSnapshot.value as? Int ?? 0
			self.bowlWeightLabel.text = String(cbw)
			self.currentBowlWeight = cbw
		}
	}

}
//handles all scrollpicker attributes
extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource{
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if(component == 0) {
			//the hours
			return hours.count
		} else {
			return minutes.count
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if lastClickedField == scheduleOneTextField {
			if(component == 0) {
				//the hours
				currentHour = hours[row]
				//return String(hours[row])
				return String(currentHour)
			} else {
				currentMinute = minutes[row]
				//return String(minutes[row])
				return String(currentMinute)
			}
		} else {
			if(component == 0) {
				//the hours
				currentHourTwo = hours[row]
				return String(hours[row])
			} else {
				currentMinuteTwo = minutes[row]
				return String(minutes[row])
			}
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		if lastClickedField == scheduleOneTextField {
		if component==0 {
			//pickerView.selectedRow(inComponent: 1)
			currentHour = hours[row]
			scheduleOneTextField.text = String(String(hours[row])+":"+String(currentMinute))
		} else {
			currentMinute = minutes[row]
			scheduleOneTextField.text = String(String(currentHour)+":"+String(minutes[row]))
		}
		} else {
			if component==0 {
				//pickerView.selectedRow(inComponent: 1)
				currentHourTwo = hours[row]
				scheduleTwoTextField.text = String(String(hours[row])+":"+String(currentMinuteTwo))
			} else {
				currentMinuteTwo = minutes[row]
				scheduleTwoTextField.text = String(String(currentHourTwo)+":"+String(minutes[row]))
			}
		}
	}
}
