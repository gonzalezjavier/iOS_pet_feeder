//
//  ViewController.swift
//  PetFeeder
//
//  Created by Javier Gonzalez on 3/20/21.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

	
	@IBOutlet weak var signUpButton: UIButton!
	
	@IBOutlet weak var loginButton: UIButton!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		setUpElements()
		//Go to home page if already logged in
		if FirebaseAuth.Auth.auth().currentUser != nil {
			let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController

			view.window?.rootViewController = homeViewController
			view.window?.makeKeyAndVisible()
		}
	}
	
	func setUpElements() {
		
		Utilities.styleFilledButton(loginButton)
		Utilities.styleFilledButton(signUpButton)
		
	}

}
