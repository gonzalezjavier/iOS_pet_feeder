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
	@IBOutlet weak var schedulingHStackView: UIStackView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var mainVStackView: UIStackView!
	@IBOutlet weak var mainStackViewTopConstraint: NSLayoutConstraint!
	let mainVStackViewTopConstraint:CGFloat = -9;
	
	var fromSignUp = false
	var dispense = 0
	var tare = 0
	var feedDuration = 0
	var currentBowlWeight = 0
	var minimumBowlWeight = 0
	var scheduleOne = ""
	var scheduleTwo = ""
	
	
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
	}
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
	
	@IBAction func dispenseFoodBtnPressed(_ sender: Any) {
		Utilities.animateButtonPress(dispenseButton)
		//Send one to the database dispense field
		guard let key = db.child("users").child(userid).child("feedinginfo").key else { return }
		let info = ["dispense": 1,
					"feedduration": self.feedDuration,
					"currentbowlweight": self.currentBowlWeight,
					"tarebowl": 0,
					"minbowlweight": self.minimumBowlWeight,
					"scheduleone":"",
					"scheduletwo":""] as [String : Any]

		let childUpdates = ["/users/\(userid)/\(key)/": info]
		db.updateChildValues(childUpdates)
	}
	
	@IBAction func tareBtnPressed(_ sender: Any) {
		Utilities.animateButtonPress(tareButton)
		//Send one to the database tare field
		guard let key = db.child("users").child(userid).child("feedinginfo").key else { return }
		let info = ["dispense": 0,
					"feedduration": self.feedDuration,
					"currentbowlweight": self.currentBowlWeight,
					"tarebowl": 1,
					"minbowlweight": self.minimumBowlWeight,
					"scheduleone":"",
					"scheduletwo":""] as [String : Any]

		let childUpdates = ["/users/\(userid)/\(key)/": info]
		db.updateChildValues(childUpdates)
	}
	
	@IBAction func scheduleOneEditted(_ sender: Any) {
		//dont think i need anything here
		
	}
	
	@IBAction func scheduleTwoEditted(_ sender: Any) {
		//i dont think i need anything here
		
		
	}
	
	@IBAction func updateButtonPressed(_ sender: Any) {
		//update database with current values of sliders and date/time
		Utilities.animateButtonPress(updateButton)
		updateUserData()
	}
	
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
			//let scheduleone = value?["scheduleone"] as? String ?? ""
			//let scheduletwo = value?["scheduletwo"] as? String ?? ""
			
			self.currentBowlWeight = Int(bowlweight)
			self.minimumBowlWeight = Int(minbowlweight)
			self.tare = 0
			self.feedDuration = Int(feedduration)
			self.dispense = 0
			
			bowlWeightLabel.text = String(bowlweight)
			feedDurationVal.text = String(feedduration)
			feedDurationSlider.value = Float(feedduration)
			minBowlWeightVal.text = String(minbowlweight)
			minBowlWeightSlider.value = Float(minbowlweight)
			}) { (error) in
			print(error.localizedDescription)
		}
	}
	
	
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
					"scheduleone":"",
					"scheduletwo":""] as [String : Any]
		let childUpdates = ["/users/\(userid)/\(key)/": info]
		db.updateChildValues(childUpdates)
	}
	
	func signOutUser() {
		do {
			try FirebaseAuth.Auth.auth().signOut()
			performSegue(withIdentifier: "unwindToOne", sender: self)
			print("signed out successfully")
		} catch {
			print("cant sign out")
		}
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
	
	func observeCurrentBowlWeight() {
		db.child("users").child(userid).child("feedinginfo/currentbowlweight").observe(.value) { (DataSnapshot) in
			let cbw = DataSnapshot.value as? Int ?? 0
			self.bowlWeightLabel.text = String(cbw)
			self.currentBowlWeight = cbw
		}
	}

}
