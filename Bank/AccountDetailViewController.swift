//
//  AccountDetailViewController.swift
//  Bank
//
//  Created by Paul Herz on 3/28/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import UIKit

class AccountDetailViewController: UITableViewController {
	
	var account: Account?
	
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
	
	func setAccount(acc: Account?) {
		Logger.sharedInstance.log("Did receive account instance data for Account \(acc!.number)", sender: self)
		self.account = acc
	}
	
	override func viewDidLoad() {
		Logger.sharedInstance.log("viewDidLoad:", sender: self)
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.setTitle()
			self.setAccountNumber()
			self.setBalance()
		}
		
		depositAmountField.delegate = moneyDelegate
		withdrawAmountField.delegate = moneyDelegate
	}
	
	@IBAction func didTouchDepositButton(sender: AnyObject) {
		Logger.sharedInstance.log("Deposit button pressed", sender: self)
		depositProcess()
	}
	
	@IBAction func didTouchWithdrawButton(sender: AnyObject) {
		Logger.sharedInstance.log("Withdraw button pressed", sender: self)
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
	}
	
	private func setTitle() {
		Logger.sharedInstance.log("Setting navbar title...", sender: self)
		// Set navbar title dynamically based on account number
		self.navigationController!.navigationBar.topItem!.title
			= "#\(self.account!.number)"
	}
	
	private func setAccountNumber() {
		accountNumberLabel.text = "Account Number \(account!.number)"
	}
	
	private func setBalance() {
		balanceLabel.text = String(format: "$%.2f", self.account!.balance)
	}
	
}
