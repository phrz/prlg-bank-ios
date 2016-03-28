//
//  UIMoneyField.swift
//  Bank
//
//  Created by Paul Herz on 3/28/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import UIKit

// Money formatting solution based on
// [CITE] http://stackoverflow.com/q/21078572/

class UIMoneyFieldDelegate: NSObject, UITextFieldDelegate {
	
	let currencySign = "$"
	
	func textField(textField: UITextField,
	               shouldChangeCharactersInRange range: NSRange,
				   replacementString string: String) -> Bool
	{
		let newValue = NSString(string: textField.text!).stringByReplacingCharactersInRange(range, withString: string)
		let components = newValue.componentsSeparatedByCharactersInSet(
			NSCharacterSet(charactersInString: "1234567890.").invertedSet
		)
		
		let decimalValue = components.joinWithSeparator("") as NSString
		let length = decimalValue.length
		
		if length > 0 {
			textField.text = "\(currencySign)\(decimalValue)"
		} else {
			textField.text = ""
		}
		
		return false
	}
	
}
