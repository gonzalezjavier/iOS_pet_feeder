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
	
	static func styleFilledButtonDashboard(_ button:UIButton) {
		
		// Filled rounded corner style
		button.backgroundColor = UIColor.init(red: 50/255, green: 175/255, blue: 100/255, alpha: 1)
		button.layer.cornerRadius = 50.0
		button.tintColor = UIColor.white
	}
	
	static func styleDayOfWeekButton(_ button:UIButton) {
		//button.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
		button.layer.cornerRadius = 10
		button.layer.borderColor = CGColor.init(red: 50/255, green: 175/255, blue: 100/255, alpha: 1)
		button.layer.borderWidth = 2
		button.setTitleColor(UIColor.white, for: .normal)
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
		//button.tintColor = UIColor.init(red: 50/255, green: 175/255, blue: 100/255, alpha: 1)
	}
	
	static func isPasswordValid(_ password : String) -> Bool {
		
		let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
		return passwordTest.evaluate(with: password)
	}
	
	static func animateButtonPress(_ button:UIButton) {
		UIView.animate(withDuration: 0.1,
			animations: {
				button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
			},
			completion: { _ in
				UIView.animate(withDuration: 0.1) {
					button.transform = CGAffineTransform.identity
				}
			})
	}
	
}
