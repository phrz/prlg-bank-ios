//
//  UIMoneyField.swift
//  Bank
//
//  Created by Paul Herz on 3/29/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import UIKit

class UIMoneyField: UIFormField {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		createAccessoryBar()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		createAccessoryBar()
	}
	
	private func createAccessoryBar() {
		// Create accessory view for transfer field
		// Based on example code:
		// [CITE] http://stackoverflow.com/a/23904935/3592716
		
		let doneBar = UIToolbar(
			frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 50)
		)
		
		doneBar.items = [
			UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
				target: self, action: nil),
			UIBarButtonItem(barButtonSystemItem: .Done,
				target: self, action: #selector(self.doneButtonPressed))
		]
		
		doneBar.sizeToFit()
		self.inputAccessoryView = doneBar
	}
	
	func doneButtonPressed() {
		Logger.sharedInstance.log("Numpad `Done` button pressed.", sender: self)
		Logger.sharedInstance.log("Resigning first responder (dismissing keyboard)...", sender: self)
		self.resignFirstResponder()
	}
	
}
