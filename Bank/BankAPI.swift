//
//  BankAPIHandler.swift
//  Bank
//
//  Created by Paul Herz on 3/27/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

protocol BankAPIDelegate: class {
	func didEncounterAuthError(message: String)
	func didReceiveAuthResults(withStatus status: Int)
	
	func didEncounterAccountsError(message: String)
	func didLoadAccounts()
	
	func didEncounterDepositError(message: String)
	func didReceiveDepositResults(withStatus status: Int)
	
	func didEncounterWithdrawError(message: String)
	func didReceiveWithdrawResults(withStatus status: Int)
	
	func didEncounterTransferError(message: String)
	func didReceiveTransferResults(withStatus status: Int)
}

class BankAPI {
	
	let baseAPI = "http://paulherz.com/bank"
	var nonce: String?
	var accountsCache = [String: Account]()
	
	weak var delegate: BankAPIDelegate?
	
	func authenticate(username username: String, password: String) {
		
		let pSafe = Array(count: password.characters.count, repeatedValue: "•").joinWithSeparator("")
		
		Logger.sharedInstance.log("authenticate: username:\"\(username)\" password: \"\(pSafe)\"", sender: self)
		
		guard !username.isEmpty else {
			let error = "The username is empty"
			Logger.sharedInstance.log(error, sender: self, level: .Error)
			delegate?.didEncounterAuthError(error)
			return
		}
		
		guard !password.isEmpty else {
			let error = "The password is empty"
			Logger.sharedInstance.log(error, sender: self, level: .Error)
			delegate?.didEncounterAuthError(error)
			return
		}
		
		let session = NSURLSession.sharedSession()
		let authURI = NSURL(string: baseAPI + "/login.php")
		
		// Create the request with Accept and Content-Type headers, POST method
		let req = NSMutableURLRequest(URL: authURI!)
		req.setValue("application/json", forHTTPHeaderField: "Accept")
		req.setValue("application/json", forHTTPHeaderField: "Content-Type")
		req.HTTPMethod = "POST"
		
		// Build parameter body
		let params = ["username": username, "password": password]
		
		do {
			let reqData: NSData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
			req.HTTPBody = reqData
		} catch {
			Logger.sharedInstance.log("Calling didEncounterAuthError on delegate (JSON Error)", sender: self)
			delegate?.didEncounterAuthError("JSON error")
		}
		
		// HTTP connection will be made asynchronously, so we're using the
		// delegate (observer) pattern with callbacks to handle the result in
		// a similarly async manner.
		let task = session.dataTaskWithRequest(req) { (data, res, err) in
			// Handle connection errors
			if let error = err {
				Logger.sharedInstance.log("Calling didEncounterAuthError on delegate", sender: self)
				Logger.sharedInstance.log(error.localizedDescription, sender: self, level: .Error)
				self.delegate?.didEncounterAuthError(error.localizedDescription)
				return
			}
			
			// Downcast NSURLResponse to NSHTTPResponse
			let httpRes = res as! NSHTTPURLResponse
			
			// Handle status codes
			Logger.sharedInstance.log("Calling didReceiveAuthResults on delegate", sender: self)
			self.delegate?.didReceiveAuthResults(withStatus: httpRes.statusCode)
		}
		
		Logger.sharedInstance.log("Resuming authentication NSURLSessionDataTask", sender: self)
		task.resume()
	} // authenticate
	
	
	func loadAccounts() {
		let session = NSURLSession.sharedSession()
		let authURI = NSURL(string: baseAPI + "/accounts.php")
		
		self.accountsCache.removeAll()
		
		// Create the request with Accept and Content-Type headers, POST method
		let req = NSMutableURLRequest(URL: authURI!)
		req.setValue("application/json", forHTTPHeaderField: "Accept")
		req.setValue("application/json", forHTTPHeaderField: "Content-Type")
		req.HTTPMethod = "GET"
		
		let task = session.dataTaskWithRequest(req) { (data, res, err) in
			// Handle connection errors
			if let error = err {
				Logger.sharedInstance.log(error.localizedDescription, sender: self, level: .Error)
				self.delegate?.didEncounterAccountsError(error.localizedDescription)
				return
			}
			
			// Parse the response body
			do {
				let json = try NSJSONSerialization
					.JSONObjectWithData(data!, options: .AllowFragments)
				
				let accounts = json["accounts"] as? [[String: AnyObject]]
				self.nonce = json["nonce"] as? String
				
				Logger.sharedInstance.log("Set nonce to \(self.nonce)", sender: self)
				
				for account in accounts! {
					let num = account["number"] as! String
					var bal = Double(account["balance"] as! String)!
					bal = Double(round(100*bal)/100) // fix rounding
					self.accountsCache[num] = Account(number: num, balance: bal)
				}
			} catch {
				Logger.sharedInstance.log("Error serializing JSON", sender: self, level: .Error)
			}
			
			Logger.sharedInstance.log("Calling delegate.didLoadAccounts:", sender: self)
			self.delegate?.didLoadAccounts()
		}
		
		Logger.sharedInstance.log("Resuming loadAccounts NSURLSessionDataTask", sender: self)
		task.resume()
	} // loadAccounts
	
	func stripMoneyString(text: String) -> String {
		// String filtering solution based on:
		// [CITE] http://stackoverflow.com/a/32851930/3592716
		
		let limitSet = Set("0123456789.".characters)
		return String(text.characters.filter { limitSet.contains($0) })
	}

	
	func deposit(amountValue: String, toAccount account: String) {
		let session = NSURLSession.sharedSession()
		let authURI = NSURL(string: baseAPI + "/deposit.php")
		
		Logger.sharedInstance.log("deposit: amountValue:\(amountValue) toAccount: \"\(account)\"", sender: self)
		
		// Validation
		guard let amount = Double(stripMoneyString(amountValue)) else {
			let error = "Cannot convert the given amountValue"
			Logger.sharedInstance.log(error, sender: self, level: .Error)
			delegate?.didEncounterDepositError(error)
			return
		}
		
		// Create the request with Accept and Content-Type headers, POST method
		let req = NSMutableURLRequest(URL: authURI!)
		req.setValue("application/json", forHTTPHeaderField: "Accept")
		req.setValue("application/json", forHTTPHeaderField: "Content-Type")
		req.HTTPMethod = "POST"
		
		// Build parameter body
		let params = ["amount": amount, "toAccount": account, "nonce": self.nonce!]
		
		do {
			let reqData: NSData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
			req.HTTPBody = reqData
		} catch {
			Logger.sharedInstance.log("Calling didEncounterDepositError on delegate (JSON Error)", sender: self)
			delegate?.didEncounterDepositError("JSON error")
		}
		
		// HTTP connection will be made asynchronously, so we're using the
		// delegate (observer) pattern with callbacks to handle the result in
		// a similarly async manner.
		let task = session.dataTaskWithRequest(req) { (data, res, err) in
			// Handle connection errors
			if let error = err {
				Logger.sharedInstance.log("Calling didEncounterDepositError on delegate", sender: self)
				Logger.sharedInstance.log(error.localizedDescription, sender: self, level: .Error)
				self.delegate?.didEncounterDepositError(error.localizedDescription)
				return
			}
			
			// Handle status codes
			let httpRes = res as! NSHTTPURLResponse
			
			Logger.sharedInstance.log("Calling didReceiveDepositResults on delegate", sender: self)
			self.delegate?.didReceiveDepositResults(withStatus: httpRes.statusCode)
		}
		
		Logger.sharedInstance.log("Resuming deposit NSURLSessionDataTask", sender: self)
		task.resume()
	} // deposit
	
	
	func withdraw(amountValue: String, fromAccount account: String) {
		let session = NSURLSession.sharedSession()
		let authURI = NSURL(string: baseAPI + "/withdraw.php")
		
		Logger.sharedInstance.log("withdraw: amountValue:\(amountValue) fromAccount: \"\(account)\"", sender: self)
		
		// Validation
		guard let amount = Double(stripMoneyString(amountValue)) else {
			let error = "Cannot convert the given amountValue"
			Logger.sharedInstance.log(error, sender: self, level: .Error)
			delegate?.didEncounterWithdrawError(error)
			return
		}
		
		// Create the request with Accept and Content-Type headers, POST method
		let req = NSMutableURLRequest(URL: authURI!)
		req.setValue("application/json", forHTTPHeaderField: "Accept")
		req.setValue("application/json", forHTTPHeaderField: "Content-Type")
		req.HTTPMethod = "POST"
		
		// Build parameter body
		let params = ["amount": amount, "fromAccount": account, "nonce": self.nonce!]
		
		do {
			let reqData: NSData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
			req.HTTPBody = reqData
		} catch {
			Logger.sharedInstance.log("Calling didEncounterWithdrawError on delegate (JSON Error)", sender: self)
			delegate?.didEncounterWithdrawError("JSON error")
		}
		
		// HTTP connection will be made asynchronously, so we're using the
		// delegate (observer) pattern with callbacks to handle the result in
		// a similarly async manner.
		let task = session.dataTaskWithRequest(req) { (data, res, err) in
			// Handle connection errors
			if let error = err {
				Logger.sharedInstance.log("Calling didEncounterWithdrawError on delegate", sender: self)
				Logger.sharedInstance.log(error.localizedDescription, sender: self, level: .Error)
				self.delegate?.didEncounterWithdrawError(error.localizedDescription)
				return
			}
			
			// Handle status codes
			let httpRes = res as! NSHTTPURLResponse
			
			Logger.sharedInstance.log("Calling didReceiveWithdrawResults on delegate", sender: self)
			self.delegate?.didReceiveWithdrawResults(withStatus: httpRes.statusCode)
		}
		
		Logger.sharedInstance.log("Resuming withdraw NSURLSessionDataTask", sender: self)
		task.resume()
	} // withdraw
	
	
	func transfer(amountValue: String, fromAccount: String, toAccount: String) {
		let session = NSURLSession.sharedSession()
		let authURI = NSURL(string: baseAPI + "/transfer.php")
		
		Logger.sharedInstance.log("transfer: amountValue:\(amountValue) fromAccount: \"\(fromAccount)\" toAccount: \"\(toAccount)\"", sender: self)
		
		// Validation
		guard let amount = Double(stripMoneyString(amountValue)) else {
			let error = "Cannot convert the given amountValue"
			Logger.sharedInstance.log(error, sender: self, level: .Error)
			delegate?.didEncounterTransferError(error)
			return
		}
		
		// Create the request with Accept and Content-Type headers, POST method
		let req = NSMutableURLRequest(URL: authURI!)
		req.setValue("application/json", forHTTPHeaderField: "Accept")
		req.setValue("application/json", forHTTPHeaderField: "Content-Type")
		req.HTTPMethod = "POST"
		
		// Build parameter body
		let params = ["amount": amount, "fromAccount": fromAccount, "toAccount": toAccount, "nonce": self.nonce!]
		
		do {
			let reqData: NSData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
			req.HTTPBody = reqData
		} catch {
			Logger.sharedInstance.log("Calling didEncounterTransferError on delegate (JSON Error)", sender: self)
			delegate?.didEncounterTransferError("JSON error")
		}
		
		// HTTP connection will be made asynchronously, so we're using the
		// delegate (observer) pattern with callbacks to handle the result in
		// a similarly async manner.
		let task = session.dataTaskWithRequest(req) { (data, res, err) in
			// Handle connection errors
			if let error = err {
				Logger.sharedInstance.log("Calling didEncounterTransferError on delegate", sender: self)
				Logger.sharedInstance.log(error.localizedDescription, sender: self, level: .Error)
				self.delegate?.didEncounterTransferError(error.localizedDescription)
				return
			}
			
			// Handle status codes
			let httpRes = res as! NSHTTPURLResponse
			
			Logger.sharedInstance.log("Calling didReceiveTransferResults on delegate", sender: self)
			self.delegate?.didReceiveTransferResults(withStatus: httpRes.statusCode)
		}
		
		Logger.sharedInstance.log("Resuming transfer NSURLSessionDataTask", sender: self)
		task.resume()
		
	} // transfer
	
}