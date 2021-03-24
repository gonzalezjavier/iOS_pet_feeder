//
//  HomeViewController.swift
//  PetFeeder
//
//  Created by Javier Gonzalez on 3/20/21.
//

import UIKit
import Firebase


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
	@IBOutlet weak var schedulingHStackView: UIStackView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var mainVStackView: UIStackView!
	@IBOutlet weak var mainStackViewTopConstraint: NSLayoutConstraint!
	let mainVStackViewTopConstraint:CGFloat = -9;
	
	//Firebase references
	let db = Firestore.firestore()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		//get user data
		self.getUserData()
		//Set up Elements
		self.setUpElements()

		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //Get the users current data values
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
		
		//Set up initial values in text fields and sliders
//		feedDurationVal.text = String(Int(feedDurationSlider.value))
//		bowlWeightLabel.text = "5"
//		minBowlWeightVal.text = String(Int(minBowlWeightSlider.value))

	}
	@IBAction func signOutTapped(_ sender: Any) {
		//Sign out user
		self.signOutUser()
	}
	
	@IBAction func feedDurationSliderMoved(_ sender: Any) {
		//Update the feed duration label
		feedDurationVal.text = String(Int(feedDurationSlider.value))
	}
	
	@IBAction func minBowlWeightSliderMoved(_ sender: Any) {
		//Update min bowl weight label
		minBowlWeightVal.text = String(Int(minBowlWeightSlider.value))
		
	}
	
	@IBAction func dispenseFoodBtnPressed(_ sender: Any) {
		//Send one to the database dispense field
		let ref = db.collection("users").document(FirebaseAuth.Auth.auth().currentUser!.uid);
		ref.updateData([
			"feedinginfo.dispense": 1
		]) { err in
			if let err = err {
				print("Error updating document: \(err)")
			} else {
				print("Document successfully updated")
			}
		}
	}
	
	@IBAction func tareBtnPressed(_ sender: Any) {
		//Send one to the database tare field
		let ref = db.collection("users").document(FirebaseAuth.Auth.auth().currentUser!.uid);
		ref.updateData([
			"feedinginfo.tarebowl": 1
		]) { err in
			if let err = err {
				print("Error updating document: \(err)")
			} else {
				print("Document successfully updated")
			}
		}
	}
	
	@IBAction func scheduleOneEditted(_ sender: Any) {
		//dont think i need anything here
		
	}
	
	@IBAction func scheduleTwoEditted(_ sender: Any) {
		//i dont think i need anything here
		
		
	}
	
	@IBAction func updateButtonPressed(_ sender: Any) {
		//update database with current values of sliders and date/time
		updateUserData()
	}
	
	func getUserData() {
		let feedingInfoRef = db.collection("users").document(FirebaseAuth.Auth.auth().currentUser!.uid)
		

		feedingInfoRef.getDocument { [self] (document, error) in
			if let document = document, document.exists {
				let data = document.data()
				let feedingInfo = "\(String(describing: data!["feedinginfo"]))"
				
				//go through each value and store locally
				var lines = feedingInfo.components(separatedBy: .newlines)
				lines.removeFirst()
				lines.removeLast()
				var valueArray = Array<Int>()
				//Gets all integer values to be stored
				for i in 0...6 {
					let tempLine = lines[i].components(separatedBy: CharacterSet.decimalDigits.inverted)
					if ((i < 4) || (i > 5)) { //Not schedules
						//get values and add to values array
						valueArray.append(self.getValues(arr: tempLine))
					} else {
						//get the schedules
					}
				}
				//Store each value in respective local variable
				bowlWeightLabel.text = String(valueArray[0])
				feedDurationVal.text = String(valueArray[2])
				feedDurationSlider.value = Float(valueArray[2])
				minBowlWeightVal.text = String(valueArray[3])
				minBowlWeightSlider.value = Float(valueArray[3])
				
			} else {
				print("Document does not exist")
			}
		}
	}
	
	func getValues(arr: Array<String>) -> Int {
		var num = 0
		for item in arr {
			if let number = Int(item) {
				num = number
			}
		}
		return num
	}
	
	func updateUserData() {
		//update
		let ref = db.collection("users").document(FirebaseAuth.Auth.auth().currentUser!.uid);

		// Set the feed duration and min bow weight field to updated values
		ref.updateData([
			"feedinginfo.feedduration": Int(feedDurationSlider.value),
			"feedinginfo.minbowlweight": Int(minBowlWeightSlider.value)
		]) { err in
			if let err = err {
				print("Error updating document: \(err)")
			} else {
				print("Document successfully updated")
			}
		}
		
	}
	
	func signOutUser() {
		do {
			try FirebaseAuth.Auth.auth().signOut()
			transitionToLoginSignUp()
			print("signed out successfully")
		} catch {
			print("cant sign out")
		}
	}
	
	func transitionToLoginSignUp() {
		let loginSignUpViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginSignUpController) as? ViewController
		
		view.window?.rootViewController = loginSignUpViewController
		view.window?.makeKeyAndVisible()
	}
	
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
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

}
