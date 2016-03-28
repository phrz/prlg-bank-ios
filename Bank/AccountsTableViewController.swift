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
	
	override func viewDidLoad() {
		accounts.append(Account(number: "0001", balance: 123.10))
		accounts.append(Account(number: "0002", balance: 23.10))
		accounts.append(Account(number: "0003", balance: 81.47))
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
