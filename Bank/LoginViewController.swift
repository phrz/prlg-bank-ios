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
		addObservers()
	}
	
	required init(coder aDecoder: NSCoder) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(coder: aDecoder)!
		addObservers()
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
	
	func addObservers() {
		// Auth Error Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
		    selector: #selector(LoginViewController.authErrorCallback),
		    name: authErrorNotification,
		    object: nil
		)
		
		// Auth Results Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(LoginViewController.authResultsCallback),
			name: authResultsNotification,
			object: nil
		)
	}
	
	func loginProcess() {
		// check the submitting flag
		guard !self.submitting else {
			NSLog("Double submission of login form prevented.")
			return
		}
		
		// set the submitting flag to disable
		// buttons and prevent double-submission
		self.submitting = true
		
		// Disable the login button
		loginButton.enabled = false
		
		// Start the spinner
		spinner.startAnimating()
		
		// Submit the form with the BankAPIHandler
		let userValue = usernameField.text
		let passValue = passwordField.text
		
		let api = self.appDelegate.api
		
		api.authenticate(username: userValue!, password: passValue!)
	}
	
	func authErrorCallback(notification: NSNotification) {
		let info = notification.userInfo
		let message = info!["message"] as! String
		NSLog("authErrorCallback")
		
		displayAuthError(message)
		
		reenableLoginForm()
	}
	
	func authResultsCallback(notification: NSNotification) {
		let info = notification.userInfo
		let status = info!["status"]
		NSLog("authResultsCallback")
		
		switch status as! Int {
		case 401:
			displayAuthError("Check your username or password")
		case 200:
			NSOperationQueue.mainQueue().addOperationWithBlock() {
				self.performSegueWithIdentifier("showAccountsSegue", sender: self)
			}
		default:
			NSLog("Unknown status returned: \(status!)")
		}
		
		reenableLoginForm()
	}
	
	func reenableLoginForm() {
		// Make UI changes FROM MAIN THREAD
		// (otherwise things like stopping the spinner
		//  will take ages to update in the UI)
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.spinner.stopAnimating()
			self.loginButton.enabled = true
		}
		
		self.submitting = false
	}
	
	func displayAuthError(msg: String) {
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			
			let alert = UIAlertController(
				title: "Error",
				message: msg,
				preferredStyle: UIAlertControllerStyle.Alert
			)
			alert.addAction(
				UIAlertAction(
					title: "OK",
					style: UIAlertActionStyle.Default,
					handler: nil
				)
			)
			self.presentViewController(alert, animated: true, completion: nil)
		}
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

