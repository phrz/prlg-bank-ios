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
	
	let moneyDelegate = UIMoneyFieldDelegate()
	let appDelegate: AppDelegate
	
	var fromAccounts = [Account]()
	var toAccounts = [Account]()
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.loadPickers()
		}
		
		transferAmountField.delegate = moneyDelegate
	}
	
	func loadPickers() {
		self.fromAccounts = self.appDelegate.api.accountsCache
		self.toAccounts = self.appDelegate.api.accountsCache
		
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
			print("Warning: unknown picker")
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
			print("Warning: unknown picker")
			return ""
		}
	}
 
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		// Do nothing
	}
	
	
}
