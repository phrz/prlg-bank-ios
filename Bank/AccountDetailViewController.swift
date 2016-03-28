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
		NSLog("Account set: \(acc?.number)")
		self.account = acc
	}
	
	override func viewDidLoad() {
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.setAccountNumber()
			self.setBalance()
		}
		
		depositAmountField.delegate = moneyDelegate
		withdrawAmountField.delegate = moneyDelegate
	}
	
	private func setAccountNumber() {
		accountNumberLabel.text = "Account Number \(account!.number)"
	}
	
	private func setBalance() {
		balanceLabel.text = String(format: "$%.2f", self.account!.balance)
	}
}
