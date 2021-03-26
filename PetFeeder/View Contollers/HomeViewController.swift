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
	
	//Firebase references
	let db = Firestore.firestore()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		//get user data
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			//after delay get current values
			self.getUserData()
		}
		//Set up Elements
		self.setUpElements()

		
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
		let dbref = Database.database().reference()
		
		let userID = Auth.auth().currentUser?.uid
		dbref.child("users").child(userID!).child("feedinginfo").observeSingleEvent(of: .value, with: { [self] (snapshot) in
			// Get user value
			let value = snapshot.value as? NSDictionary
			let bowlweight = value?["currentbowlweight"] as? Int64 ?? 0
			let minbowlweight = value?["minbowlweight"] as? Int64 ?? 0
			//let tarebowl = value?["tarebowl"] as? Int64 ?? 0
			let feedduration = value?["feedduration"] as? Int64 ?? 0
			//let dispense = value?["dispense"] as? Int64 ?? 0
			//let scheduleone = value?["scheduleone"] as? String ?? ""
			//let scheduletwo = value?["scheduletwo"] as? String ?? ""
			
			bowlWeightLabel.text = String(bowlweight)
			feedDurationVal.text = String(feedduration)
			feedDurationSlider.value = Float(feedduration)
			minBowlWeightVal.text = String(minbowlweight)
			minBowlWeightSlider.value = Float(minbowlweight)

			// ...
			}) { (error) in
			print(error.localizedDescription)
		}
	}
	
	
	func updateUserData() {
		let dbref = Database.database().reference()
		let userid = Auth.auth().currentUser?.uid
		guard let key = dbref.child("users").child(userid!).child("feedinginfo").key else { return }
		let info = ["dispense": 0,
					"feedduration": Int(feedDurationSlider.value),
					"currentbowlweight": Int(bowlWeightLabel.text!)!,
					"tarebowl": 0,
					"minbowlweight": Int(minBowlWeightSlider.value),
					"scheduleone":"",
					"scheduletwo":""] as [String : Any]
		let childUpdates = ["/users/\(userid!)/\(key)/": info]
		dbref.updateChildValues(childUpdates)

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

}
