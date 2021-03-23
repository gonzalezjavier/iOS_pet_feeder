//
//  LoginViewController.swift
//  PetFeeder
//
//  Created by Javier Gonzalez on 3/20/21.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
	
	
	@IBOutlet weak var emailTextField: UITextField!
	
	
	@IBOutlet weak var passwordTextField: UITextField!
	
	@IBOutlet weak var loginButton: UIButton!
	
	
	@IBOutlet weak var errorLabel: UILabel!
	
	
	@IBOutlet weak var cancelButton: UIButton!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		setUpElements()
    }
    
	func setUpElements()  {
		//Hide error label
		errorLabel.alpha = 0
		//Style the elements
		Utilities.styleTextField(emailTextField)
		Utilities.styleTextField(passwordTextField)
		Utilities.styleFilledButton(loginButton)
		Utilities.styleFilledButton(cancelButton)
		//set up text field delegates
		emailTextField.delegate = self
		passwordTextField.delegate = self
		//Set up return key type
		emailTextField.returnKeyType = .done
		passwordTextField.returnKeyType = .done
		
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func validateFields() -> String? {
		//Check that all feilds are filled in
		if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			return "Please fill in all fields"
		}
		return nil
	}
	func showError(_ message:String) {
		errorLabel.text = message
		errorLabel.alpha = 1
	}
	
	func transitionToHome() {
		let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
		
		view.window?.rootViewController = homeViewController
		view.window?.makeKeyAndVisible()
	
	}
	
	@IBAction func loginTapped(_ sender: Any) {
		//Validates that text fields are filled in
		let error = validateFields()
		
		if error != nil {
			//There is some error with the text fields
			showError(error!)
		} else {
			//Continue with login
			//Create cleaned versions of credentials
			let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
			let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
			
			//Sign in the user
			Auth.auth().signIn(withEmail: email, password: password) {(result, error) in
				if error != nil {
					//Couldn't Sign in
					self.errorLabel.text = error!.localizedDescription
					self.errorLabel.alpha = 1
				} else {
					//transition to home
					self.transitionToHome()
				}
			}
				
		}
		
		
	}


}
