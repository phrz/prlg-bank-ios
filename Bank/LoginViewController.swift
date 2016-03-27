//
//  ViewController.swift
//  Bank
//
//  Created by Paul Herz on 3/27/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	var appDelegate: AppDelegate
	var submitting: Bool = false
	
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init(coder aDecoder: NSCoder) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(coder: aDecoder)!
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		usernameField.delegate = self
		passwordField.delegate = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func loginButtonPressed(sender: AnyObject) {
		loginProcess()
	}
	
	func loginProcess() {
		// check the submitting flag
		guard !self.submitting else {
			print("already submitting!")
			return
		}
		
		// set the submitting flag to disable
		// buttons and prevent double-submission
		self.submitting = true
		
		// Disable the login button
		loginButton.enabled = false
		
		// Start the spinner
		let userValue = usernameField.text
		let passValue = passwordField.text
		
		let api = self.appDelegate.api
		
		if api.authenticate(username: userValue, password: passValue) {
			print("Auth success")
		} else {
			print("Auth failure")
		}
		
		// Re-enable the login button
		
	}
	
	// Solution for going to next text field in login form based on
	// discussion in thread [CITE] http://stackoverflow.com/q/1347779/
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		
		// if someone has hit return on a field that is a UIFormField,
		// which just has an added `UIFormField?` property called `nextField`,
		// we should go to said nextField (if it is not nil)
		if let formField = textField as? UIFormField {
			if let nextResponder = formField.nextField as UIResponder! {
				// this field has an IBOutlet referencing the next text field,
				// so switch to it.
				nextResponder.becomeFirstResponder()
			} else {
				// there is no next, so this is the password field, which is
				// presenting "Go" as the return button. We should dismiss
				// the keyboard and run the submit action.
				formField.resignFirstResponder()
				loginProcess()
			}
		}
		
		return false // suppress line break
	}


}

