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
	
	@IBOutlet weak var schedulingHStackView: UIStackView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var mainVStackView: UIStackView!
	@IBOutlet weak var mainStackViewTopConstraint: NSLayoutConstraint!
	let mainVStackViewTopConstraint:CGFloat = -9;
	
	//Firebase references
	let db = Firestore.firestore()
	
	
	//User Data
	var uid: String = ""
	var dispense: Int = 0
	var feedDuration: Int = 0
	var currentBowlWeight: Int = 0
	var tareBowl: Int = 0
	var minBowlWeight: Int = 0
	var scheduleOne: String = ""
	var scheduleTwo: String = ""

	
    override func viewDidLoad() {
        super.viewDidLoad()
		//Set up Elements
		self.setUpElements()
		//Listen for keyboard
//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		
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
		//sets the textfield delegates
		scheduleOneTextField.delegate = self
		scheduleTwoTextField.delegate = self
		//Sets the return key type
		scheduleOneTextField.returnKeyType = .done
		scheduleTwoTextField.returnKeyType = .done
		
		//Set up initial values in text fields
		feedDurationVal.text = String(Int(feedDurationSlider.value))
		bowlWeightLabel.text = "5"
		minBowlWeightVal.text = String(Int(minBowlWeightSlider.value))
	}
	@IBAction func signOutTapped(_ sender: Any) {
		//Sign out user
		self.signOutUser()
	}
	
	@IBAction func feedDurationSliderMoved(_ sender: Any) {
		//Update the feed duration label
		feedDurationVal.text = String(Int(feedDurationSlider.value))
		//Send updated data to database
		
	}
	
	@IBAction func minBowlWeightSliderMoved(_ sender: Any) {
		//Update min bowl weight label
		minBowlWeightVal.text = String(Int(minBowlWeightSlider.value))
		//Send updated data to database
		
	}
	
	@IBAction func dispenseFoodBtnPressed(_ sender: Any) {
		//print out data to test retrieving data
		getUserData()
	}
	
	@IBAction func tareBtnPressed(_ sender: Any) {
		
		
	}
	
	@IBAction func scheduleOneEditted(_ sender: Any) {
	}
	
	@IBAction func scheduleTwoEditted(_ sender: Any) {
	}
	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
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
	
	func getUserData() {
		let feedingInfoRef = db.collection("users").document(FirebaseAuth.Auth.auth().currentUser!.uid)
		
		feedingInfoRef.getDocument { (document, error) in
			if let document = document, document.exists {
				let documentDescription = document.data().map(String.init(describing:)) ?? "nil"
				print("document data: \(documentDescription)")
			} else {
				print("Document does not exist")
			}
		}
	}
	
	func updateUserData() {
		
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

}
