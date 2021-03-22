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
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
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
