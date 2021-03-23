//
//  HomeViewController.swift
//  PetFeeder
//
//  Created by Javier Gonzalez on 3/20/21.
//

import UIKit
import Firebase


class HomeViewController: UIViewController {
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
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		//Set up Elements
		self.setUpElements()
        //Get the users current data values
    }
    
	func setUpElements() {
		Utilities.styleFilledButtonDashboard(dispenseButton)
		Utilities.styleFilledButtonDashboard(tareButton)
		Utilities.styleFilledButton(signOutButton)
		Utilities.styleTextField(scheduleOneTextField)
		Utilities.styleTextField(scheduleTwoTextField)
		
		//Set up initial values in text fields
		feedDurationVal.text = "10"
		bowlWeightLabel.text = "0"
		minBowlWeightVal.text = "5"
	}
	@IBAction func signOutTapped(_ sender: Any) {
		//Sign out user
		self.signOutUser()
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
