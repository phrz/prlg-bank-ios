//
//  TransferViewController.swift
//  Bank
//
//  Created by Paul Herz on 3/29/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import UIKit

class TransferViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	
	@IBOutlet weak var transferAmountField: UITextField!
	@IBOutlet weak var fromAccountPicker: UIPickerView!
	@IBOutlet weak var toAccountPicker: UIPickerView!
	@IBOutlet weak var transferButton: UIButton!
	@IBOutlet weak var transferSpinner: UIActivityIndicatorView!
	
	let moneyDelegate = UIMoneyFieldDelegate()
	let appDelegate: AppDelegate
	
	var fromAccounts = [Account]()
	var toAccounts = [Account]()
	
	var currentFromValue: Account?
	var currentToValue: Account?
	
	var submitting: Bool = false
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.addObservers()
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(coder: aDecoder)
		self.addObservers()
	}
	
	func addObservers() {
		Logger.sharedInstance.log("Adding observers for Transfer API events...", sender: self)
		
		// Transfer Error Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(TransferViewController.transferErrorCallback),
			name: transferErrorNotification,
			object: nil
		)
		
		// Transfer Results Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(TransferViewController.transferResultsCallback),
			name: transferResultsNotification,
			object: nil
		)
	}
	
	override func viewDidLoad() {
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.loadPickers()
		}
		transferAmountField.delegate = moneyDelegate
	}
	
	
	func loadPickers() {
		self.fromAccounts = Array(self.appDelegate.api.accountsCache.values)
		self.toAccounts = self.fromAccounts
		
		fromAccountPicker.dataSource = self
		fromAccountPicker.delegate = self
		
		toAccountPicker.dataSource = self
		toAccountPicker.delegate = self
		
		fromAccountPicker.reloadAllComponents()
		toAccountPicker.reloadAllComponents()
	}
	
	
	func reloadPickersFromCache() {
		self.appDelegate
	}
	
	
	// MARK: UIPickerViewDataSource protocol
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch pickerView {
		case fromAccountPicker:
			return self.fromAccounts.count + 1 // Including "From" header
		case toAccountPicker:
			return self.toAccounts.count + 1 // Including "To" header
		default:
			Logger.sharedInstance.log("Unknown picker", sender: self, level: .Warning)
			return 0
		}
	}
	
	// MARK: UIPickerViewDelegate protocol
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch pickerView {
		case fromAccountPicker:
			if(row == 0) { return "From" }
			return self.fromAccounts[row-1].number
		case toAccountPicker:
			if(row == 0) { return "To" }
			return self.toAccounts[row-1].number
		default:
			Logger.sharedInstance.log("Unknown picker", sender: self, level: .Warning)
			return ""
		}
	}
 
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		Logger.sharedInstance.log("User selected row #\(row) in component #\(component) in a picker.", sender: self)
		
		switch pickerView {
		case fromAccountPicker:
			if row != 0 {
				currentFromValue = self.fromAccounts[row-1] // excluding spinner header at [0] "From"
				Logger.sharedInstance.log("From account selected: \(currentFromValue!.number)", sender: self)
			} else {
				currentFromValue = nil
				Logger.sharedInstance.log("Header row selected. Set current to nil", sender: self)
			}
			
		case toAccountPicker:
			if row != 0 {
				currentToValue = self.toAccounts[row-1] // excluding spinner header at [0] "To"
				Logger.sharedInstance.log("To account selected: \(currentToValue!.number)", sender: self)
			} else {
				currentToValue = nil
				Logger.sharedInstance.log("Header row selected. Set current to nil", sender: self)

			}
			
		default:
			Logger.sharedInstance.log("Unknown picker", sender: self, level: .Warning)
		}
		
	}
	
	// MARK: Form submission functions
	@IBAction func didTouchTransferButton(sender: AnyObject) {
		Logger.sharedInstance.log("Transfer button pressed", sender: self)
		self.view.endEditing(true)
		transferProcess()
	}
	
	
	func transferProcess() {
		Logger.sharedInstance.log("transferProcess:", sender: self)
		
		// check the submitting flag
		guard !self.submitting else {
			Logger.sharedInstance.log("Double submission of transfer form prevented.", sender: self, level: .Warning)
			return
		}
		
		// set the submitting flag to disable
		// buttons and prevent double-submission
		self.submitting = true
		
		// Disable the login button
		transferButton.enabled = false
		
		// Start the spinner
		transferSpinner.startAnimating()
		
		let CFV = self.currentFromValue
		let CTV = self.currentToValue
		
		// Check that the amount field isn't empty
		guard self.transferAmountField.text?.characters.count != 0 else {
			Logger.sharedInstance.log("Transfer amount empty", sender: self, level: .Error)
			displayTransferError("Please enter an amount to transfer")
			reenableTransferForm()
			return
		}
		
		// Check that the pickers have both selected an account
		guard let fromAccount = CFV?.number else {
			Logger.sharedInstance.log("From account not selected", sender: self, level: .Error)
			displayTransferError("Please select a From account")
			reenableTransferForm()
			return
		}
		
		guard let toAccount = CTV?.number else {
			Logger.sharedInstance.log("To account not selected", sender: self, level: .Error)
			displayTransferError("Please select a To account")
			reenableTransferForm()
			return
		}
		
//		var fromAccount: String = ""
//		var toAccount: String = ""
//		if (let currentFromValue = currentFromValue and ) {
//			fromAccount = currentFromValue.number
//		} else {
//			_ = self.currentFromValue!
//		}
//		
//		if let currentToValue = currentToValue {
//			toAccount = currentToValue.number
//		} else {
//			_ = self.currentToValue!
//		}
		
		
		// Check that the accounts are different
		guard fromAccount != toAccount else {
			Logger.sharedInstance.log("From and To accounts are the same", sender: self, level: .Error)
			displayTransferError("Make sure the To account isn't the same as the From account.")
			reenableTransferForm()
			return
		}
		
		// Submit the form with the BankAPIHandler
		let amountValue = transferAmountField.text!
		
		Logger.sharedInstance.log("Calling API to transfer \(amountValue) from account \(fromAccount) to account \(toAccount)", sender: self)
		
		let api = self.appDelegate.api
		api.transfer(amountValue, fromAccount: fromAccount,toAccount: toAccount)
	}
	
	
	func transferErrorCallback(notification: NSNotification) {
		let info = notification.userInfo
		let message = info!["message"] as! String
		Logger.sharedInstance.log("transferErrorCallback: \"\(message)\"", sender: self, level: .Error)
		
		displayTransferError(message)
		
		reenableTransferForm()
	}
	
	func transferResultsCallback(notification: NSNotification) {
		let info = notification.userInfo
		let status = info!["status"]
		
		Logger.sharedInstance.log("transferResultsCallback: \(status!)", sender: self)
		
		switch status as! Int {
		case 400: // Bad Request
			displayTransferError("Could not complete transfer.")
		case 200:
			Logger.sharedInstance.log("Reloading accounts information...", sender: self)
			self.appDelegate.api.loadAccounts()
			NSOperationQueue.mainQueue().addOperationWithBlock {
				self.transferAmountField.text = ""
			}
		default:
			Logger.sharedInstance.log(
				"transferResultsCallback: Unexpected HTTP status code returned: \(status!)",
				sender: self,
				level: .Error
			)
		}
		
		reenableTransferForm()
	}
	
	
	func displayTransferError(msg: String) {
		Logger.sharedInstance.log("displayTransferError: \"\(msg)\"", sender: self)
		
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
	
	
	func reenableTransferForm() {
		// Make UI changes FROM MAIN THREAD
		// (otherwise things like stopping the spinner
		//  will take ages to update in the UI)
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.transferSpinner.stopAnimating()
			self.transferButton.enabled = true
		}
		
		self.submitting = false
	}
	
	
}
