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
	
	override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init(coder aDecoder: NSCoder) {
		self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		super.init(coder: aDecoder)!
	}
	
	override func viewDidLoad() {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let api = appDelegate.api
		
		api.loadAccounts()
	}
	
	// DataSource methods
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView
		(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.accounts.count
	}
	
	override func tableView
		(tableView: UITableView,
		 cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier("accountTableViewCell")
		let account = self.accounts[indexPath.row]
		
		cell?.textLabel?.text = "#\(account.number)"
		cell?.detailTextLabel?.text = String(format: "$%.2f", account.balance)
		
		return cell!
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// self.view is the table, get the index path of the current cell
		let path: NSIndexPath = self.tableView.indexPathForSelectedRow!
		
		if let dest = segue.destinationViewController as? AccountDetailViewController {
			dest.setAccount(self.accounts[path.row])
		}
	}
}
