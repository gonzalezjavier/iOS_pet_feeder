//
//  SignUpViewController.swift
//  PetFeeder
//
//  Created by Javier Gonzalez on 3/20/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate {
	
	
	@IBOutlet weak var firstNameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var signUpButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var errorLabel: UILabel!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		setUpElements()
    }

	@IBAction func signUpTapped(_ sender: Any) {
		//Validate the text fields
		let error = validateFields()
		
		//Handle error or attempt sign-up
		if error != nil {
			//There is something wrong with the fields, show error message
			showError(error!)
			return
		} else {
			//Create User
			let err = createUserAPI()
			if err == nil {
				//success creating user, go home
				self.performSegue(withIdentifier: "signUpToHomeSegue", sender: nil)
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.destination is HomeViewController {
			let vc = segue.destination as? HomeViewController
			vc?.fromSignUp = true
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.keyboardReturn(textField)
		return true
	}
	
	func keyboardReturn(_ textField: UITextField) {
		switch textField {
		case self.firstNameTextField:
			self.lastNameTextField.becomeFirstResponder()
		case self.lastNameTextField:
			self.emailTextField.becomeFirstResponder()
		default:
			self.passwordTextField.resignFirstResponder()
			self.signUpTapped(self)
		}
	}
	
	func setUpElements() {
		//Hide the error label
		errorLabel.alpha = 0
		//Style elements
		Utilities.styleTextField(firstNameTextField)
		Utilities.styleTextField(lastNameTextField)
		Utilities.styleTextField(emailTextField)
		Utilities.styleTextField(passwordTextField)
		Utilities.styleFilledButton(signUpButton)
		Utilities.styleFilledButton(signUpButton)
		Utilities.styleFilledButton(cancelButton)
		//sets textfield delegate
		firstNameTextField.delegate = self
		lastNameTextField.delegate = self
		emailTextField.delegate = self
		passwordTextField.delegate = self
		//set return key type
		firstNameTextField.returnKeyType = .next
		firstNameTextField.returnKeyType = .next
		lastNameTextField.returnKeyType = .next
		emailTextField.returnKeyType = .next
		passwordTextField.returnKeyType = .go
	}
	
	func validateFields() -> String? {
		//Check that all feilds are filled in
		if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			return "Please fill in all fields"
		}
		
		//Check if password is secure
		let cleanPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if Utilities.isPasswordValid(cleanPassword) == false {
			return "Please make sure your password is at least 8 characters, contains a special character and a number."
		}
		return nil
	}
	
	func showError(_ message:String) {
		errorLabel.text = message
		errorLabel.alpha = 1
	}
	
	func createUserAPI() -> String?{
		//Create cleaned version of fields
		let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
		let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
		let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
		let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
		var success: String?
		//Create the user
		Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
			//check for errors
			if err != nil {
				//There was an error
				self.showError(err!.localizedDescription)
				success = "error creating user"
			} else {
				//No error, save user info
				let dbref = Database.database().reference()
				
				dbref.child("users").child(result!.user.uid).setValue(["basicinfo": ["firstname":firstName, "lastname":lastName, "email":email ,"uid": result!.user.uid], "feedinginfo": ["dispense":0, "feedduration":0, "currentbowlweight":0, "tarebowl":0, "minbowlweight":0, "scheduleone":"", "scheduletwo":""]])
			}
		}
		return success
	}	
}
