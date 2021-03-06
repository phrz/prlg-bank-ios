//
//  AccountsTableViewController.swift
//  Bank
//
//  Created by Paul Herz on 3/28/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import UIKit

class AccountsTableViewController: UITableViewController {
	
	var accounts = [Account]()
	var appDelegate: AppDelegate
	
	@IBOutlet weak var reloadButton: UIBarButtonItem!
	
	@IBAction func reloadButtonAction(sender: AnyObject) {
		Logger.sharedInstance.log("Reload button pressed", sender: self)
		self.appDelegate.api.loadAccounts()
	}
	
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
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let api = appDelegate.api
		
		api.loadAccounts()
	}
	
	func addObservers() {
		// Accounts Loaded Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(AccountsTableViewController.accountsLoadedCallback),
			name: accountsLoadedNotification,
			object: nil
		)
		
		// Accounts Error Observer
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(AccountsTableViewController.accountsErrorCallback),
			name: accountsErrorNotification,
			object: nil
		)
	}
	
//	func removeObservers() {
//		NSNotificationCenter.defaultCenter().removeObserver(self)
//	}
	
	func accountsLoadedCallback() {
		Logger.sharedInstance.log("accountsLoadedCallback:", sender: self)
		reloadAccountsTableFromCache()
	}
	
	func accountsErrorCallback() {
		Logger.sharedInstance.log("accountsErrorCallback:", sender: self)
	}
	
	func reloadAccountsTableFromCache() {
		NSOperationQueue.mainQueue().addOperationWithBlock() {
			self.accounts = Array(self.appDelegate.api.accountsCache.values)
			Logger.sharedInstance.log("copying accounts from API cache...", sender: self)
			Logger.sharedInstance.log("\(self.accounts.count) account(s) copied", sender: self)
			self.tableView.reloadData()
		}
	}
	
	// DataSource methods
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		Logger.sharedInstance.log("numberOfSectionsInTableView:", sender: self)
		return 1
	}
	
	override func tableView
		(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		Logger.sharedInstance.log("tableView:numberOfRowsInSection:", sender: self)
		return self.accounts.count
	}
	
	override func tableView
		(tableView: UITableView,
		 cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		Logger.sharedInstance.log("tableView:cellForRowAtIndexPath:", sender: self)
		
		let cell = tableView.dequeueReusableCellWithIdentifier("accountTableViewCell")
		let account = self.accounts[indexPath.row]
		
		cell?.textLabel?.text = "#\(account.number)"
		cell?.detailTextLabel?.text = String(format: "$%.2f", account.balance)
		
		return cell!
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		Logger.sharedInstance.log("Preparing to segue to account detail view", sender: self)
		
		// self.view is the table, get the index path of the current cell
		let path: NSIndexPath = self.tableView.indexPathForSelectedRow!
		
		if let dest = segue.destinationViewController as? AccountDetailViewController {
			let detailAccount = self.accounts[path.row]
			
			Logger.sharedInstance.log("Passing account instance data to account detail view", sender: self)
			dest.accountNumber = detailAccount.number
			
//			self.removeObservers()
		}
	}
}
