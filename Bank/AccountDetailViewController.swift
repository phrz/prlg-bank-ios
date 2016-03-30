//
//  AccountDetailViewController.swift
//  Bank
//
//  Created by Paul Herz on 3/28/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import UIKit

class AccountDetailViewController: UITableViewController {
	
	var account: Account {
		get {
			Logger.sharedInstance.log("Retrieving Account model for #\(accountNumber!)", sender: self)
			let accountOrNil = self.appDelegate.api.accountsCache[self.accountNumber!]
			return accountOrNil!
		}
		set {
			Logger.sharedInstance.log("Cannot set account", sender: self, level: .Error)
		}
	}
	
	var accountNumber: String?
	
	var depositSubmitting: Bool = false
	var withdrawSubmitting: Bool = false
	
	@IBOutlet weak var accountNumberLabel: UILabel!
	@IBOutlet weak var balanceLabel: UILabel!
	
	@IBOutlet weak var depositAmountField: UITextField!
	@IBOutlet weak var withdrawAmountField: UITextField!
	
	@IBOutlet weak var depositButton: UIButton!
	@IBOutlet weak var withdrawButton: UIButton!
	
	@IBOutlet weak var depositSpinner: UIActivityIndicatorView!
	@IBOutlet weak var withdrawSpinner: UIActivityIndicatorView!
	
	let moneyDelegate = UIMoneyFieldDelegate()
	let appDelegate: AppDelegate
	
	override init(style: UITableViewStyle) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(style: style)
		self.addObservers()
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(coder: aDecoder)
		self.addObservers()
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.addObservers()
	}
	
	override func viewDidLoad() {
		Logger.sharedInstance.log("viewDidLoad:", sender: self)
		
		depositAmountField.delegate = moneyDelegate
		withdrawAmountField.delegate = moneyDelegate
		
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.setTitle()
			self.setAccountNumber()
			self.setBalance()
		}
	}
	
	func depositErrorCallback(notification: NSNotification) {
		let info = notification.userInfo
		let message = info!["message"] as! String
		Logger.sharedInstance.log("depositErrorCallback: \"\(message)\"", sender: self, level: .Error)
		
		displayTransactionError(message)
		
		reenableDepositForm()
	}
	
	func depositResultsCallback(notification: NSNotification) {
		let info = notification.userInfo
		let status = info!["status"]
		
		Logger.sharedInstance.log("depositResultsCallback: \(status!)", sender: self)
		
		switch status as! Int {
		case 400: // Bad Request
			displayTransactionError("Could not complete deposit.")
		case 200:
			Logger.sharedInstance.log("Reloading accounts information...", sender: self)
			self.appDelegate.api.loadAccounts()
			NSOperationQueue.mainQueue().addOperationWithBlock {
				self.depositAmountField.text = ""
			}
		default:
			Logger.sharedInstance.log(
				"depositResultsCallback: Unexpected HTTP status code returned: \(status!)",
				sender: self,
				level: .Error
			)
		}
		
		reenableDepositForm()
	}
	
	func withdrawErrorCallback(notification: NSNotification) {
		let info = notification.userInfo
		let message = info!["message"] as! String
		Logger.sharedInstance.log("withdrawErrorCallback: \"\(message)\"", sender: self, level: .Error)
		
		displayTransactionError(message)
		
		reenableDepositForm()
	}
	
	func withdrawResultsCallback(notification: NSNotification) {
		let info = notification.userInfo
		let status = info!["status"]
		
		Logger.sharedInstance.log("withdrawResultsCallback: \(status!)", sender: self)
		
		switch status as! Int {
		case 400: // Bad Request
			displayTransactionError("Could not complete withdrawal.")
		case 409: // Conflict
			displayTransactionError("Insufficient funds to withdraw.")
		case 200:
			Logger.sharedInstance.log("Reloading accounts information...", sender: self)
			self.appDelegate.api.loadAccounts()
			NSOperationQueue.mainQueue().addOperationWithBlock {
				self.withdrawAmountField.text = ""
			}
		default:
			Logger.sharedInstance.log(
				"withdrawResultsCallback: Unexpected HTTP status code returned: \(status!)",
				sender: self,
				level: .Error
			)
		}
		
		reenableWithdrawForm()
	}
	
	func accountsLoadedCallback() {
		Logger.sharedInstance.log("accountsLoadedCallback:", sender: self)
		setTitle()
		setBalance()
	}
	
	func reenableDepositForm() {
		// Make UI changes FROM MAIN THREAD
		// (otherwise things like stopping the spinner
		//  will take ages to update in the UI)
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.depositSpinner.stopAnimating()
			self.depositButton.enabled = true
		}
		
		self.depositSubmitting = false
	}
	
	func reenableWithdrawForm() {
		// Make UI changes FROM MAIN THREAD
		// (otherwise things like stopping the spinner
		//  will take ages to update in the UI)
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.withdrawSpinner.stopAnimating()
			self.withdrawButton.enabled = true
		}
		
		self.withdrawSubmitting = false
	}
	
	func displayTransactionError(msg: String) {
		Logger.sharedInstance.log("displayTransactionError: \"\(msg)\"", sender: self)
		
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
	
	func addObservers() {
		Logger.sharedInstance.log("Adding observers for Auth API events...", sender: self)
		
		// Deposit Error Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(AccountDetailViewController.depositErrorCallback),
			name: depositErrorNotification,
			object: nil
		)
		
		// Deposit Results Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(AccountDetailViewController.depositResultsCallback),
			name: depositResultsNotification,
			object: nil
		)
		
		// Withdraw Error Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(AccountDetailViewController.withdrawErrorCallback),
			name: withdrawErrorNotification,
			object: nil
		)
		
		// Withdraw Results Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(AccountDetailViewController.withdrawResultsCallback),
			name: withdrawResultsNotification,
			object: nil
		)
		
		// Accounts Loaded Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(AccountDetailViewController.accountsLoadedCallback),
			name: accountsLoadedNotification,
			object: nil
		)
	}
	
	@IBAction func didTouchDepositButton(sender: AnyObject) {
		Logger.sharedInstance.log("Deposit button pressed", sender: self)
		self.view.endEditing(true)
		depositProcess()
	}
	
	@IBAction func didTouchWithdrawButton(sender: AnyObject) {
		Logger.sharedInstance.log("Withdraw button pressed", sender: self)
		self.view.endEditing(true)
		withdrawProcess()
	}
	
	private func depositProcess() {
		Logger.sharedInstance.log("depositProcess:", sender: self)
		
		// check the submitting flag
		guard !self.depositSubmitting else {
			Logger.sharedInstance.log("Double submission of deposit form prevented.", sender: self, level: .Warning)
			return
		}
		
		// set the submitting flag to disable
		// buttons and prevent double-submission
		self.depositSubmitting = true
		
		// Disable the login button
		depositButton.enabled = false
		
		// Start the spinner
		depositSpinner.startAnimating()
		
		// Submit the form with the BankAPIHandler
		let amountValue = depositAmountField.text!
		let toAccount = self.account.number
		
		Logger.sharedInstance.log("Calling API to deposit \(amountValue) to account \(toAccount)", sender: self)
		
		let api = self.appDelegate.api
		api.deposit(amountValue, toAccount: toAccount)
	}
	
	private func withdrawProcess() {
		Logger.sharedInstance.log("withdrawProcess:", sender: self)
		
		// check the submitting flag
		guard !self.withdrawSubmitting else {
			Logger.sharedInstance.log("Double submission of withdraw form prevented.", sender: self, level: .Warning)
			return
		}
		
		// set the submitting flag to disable
		// buttons and prevent double-submission
		self.withdrawSubmitting = true
		
		// Disable the login button
		withdrawButton.enabled = false
		
		// Start the spinner
		withdrawSpinner.startAnimating()
		
		// Submit the form with the BankAPIHandler
		let amountValue = withdrawAmountField.text!
		let fromAccount = self.account.number
		
		Logger.sharedInstance.log("Calling API to withdraw \(amountValue) from account \(fromAccount)", sender: self)
		
		let api = self.appDelegate.api
		api.withdraw(amountValue, fromAccount: fromAccount)
	}
	
	private func setTitle() {
		Logger.sharedInstance.log("Setting navbar title...", sender: self)
		// Set navbar title dynamically based on account number
		NSOperationQueue.mainQueue().addOperationWithBlock { 
			self.navigationController!.navigationBar.topItem!.title
				= "#\(self.accountNumber!)"
		}
	}
	
	private func setAccountNumber() {
		Logger.sharedInstance.log("Setting hero account number...", sender: self)
		NSOperationQueue.mainQueue().addOperationWithBlock {
			self.accountNumberLabel.text = "Account Number \(self.accountNumber!)"
		}
	}
	
	private func setBalance() {
		Logger.sharedInstance.log("Setting balance...", sender: self)
		NSOperationQueue.mainQueue().addOperationWithBlock {
			self.balanceLabel.text = String(format: "$%.2f", self.account.balance)
		}
	}
	
}
