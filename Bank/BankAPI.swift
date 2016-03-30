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
}

class BankAPI {
	
	let baseAPI = "http://paulherz.com/bank"
	var nonce: String?
	var accountsCache = [Account]()
	
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
		
		self.accountsCache = []
		
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
				
				for account in accounts! {
					let num = account["number"] as! String
					var bal = Double(account["balance"] as! String)!
					bal = Double(round(100*bal)/100) // fix rounding
					self.accountsCache.append( Account(number: num, balance: bal) )
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
	
}