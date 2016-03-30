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
	
	@IBOutlet weak var accountNumberLabel: UILabel!
	@IBOutlet weak var balanceLabel: UILabel!
	
	@IBOutlet weak var depositAmountField: UITextField!
	@IBOutlet weak var withdrawAmountField: UITextField!
	
	let moneyDelegate = UIMoneyFieldDelegate()
	
	func setAccount(acc: Account?) {
		Logger.sharedInstance.log("Account set: \(acc?.number)", sender: self)
		self.account = acc
	}
	
	override func viewDidLoad() {
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.setTitle()
			self.setAccountNumber()
			self.setBalance()
		}
		
		depositAmountField.delegate = moneyDelegate
		withdrawAmountField.delegate = moneyDelegate
	}
	
	private func setTitle() {
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
