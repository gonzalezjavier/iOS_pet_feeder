//
//  Utilities.swift
//  PetFeeder
//
//  Created by Javier Gonzalez on 3/20/21.
//

import Foundation
import UIKit

class Utilities {
	
	static func styleTextField(_ textfield:UITextField) {
		
		// Create the bottom line
		let bottomLine = CALayer()
		
		bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
		
		bottomLine.backgroundColor = UIColor.init(red: 50/255, green: 175/255, blue: 100/255, alpha: 1).cgColor
		
		// Remove border on text field
		textfield.borderStyle = .none
		
		// Add the line to the text field
		textfield.layer.addSublayer(bottomLine)
		
	}
	
	static func styleFilledButton(_ button:UIButton) {
		
		// Filled rounded corner style
		button.backgroundColor = UIColor.init(red: 50/255, green: 175/255, blue: 100/255, alpha: 1)
		button.layer.cornerRadius = 25.0
		button.tintColor = UIColor.white
	}
	
	static func isPasswordValid(_ password : String) -> Bool {
		
		let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
		return passwordTest.evaluate(with: password)
	}
	
}
