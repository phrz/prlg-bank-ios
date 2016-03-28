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
	func didLoadAccounts(accounts: [Account])
}

class BankAPI {
	
	let baseAPI = "http://paulherz.com/bank"
	
	weak var delegate: BankAPIDelegate?
	
	func authenticate(username username: String, password: String) {
		
		guard !username.isEmpty else {
			delegate?.didEncounterAuthError("The username is empty")
			return
		}
		
		guard !password.isEmpty else {
			delegate?.didEncounterAuthError("The password is empty")
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
			delegate?.didEncounterAuthError("JSON error")
		}
		
		// HTTP connection will be made asynchronously, so we're using the
		// delegate (observer) pattern with callbacks to handle the result in
		// a similarly async manner.
		let task = session.dataTaskWithRequest(req) { (data, res, err) in
			// Handle connection errors
			if let error = err {
				NSLog(error.localizedDescription)
				self.delegate?.didEncounterAuthError(error.localizedDescription)
				return
			}
			
			// Downcast NSURLResponse to NSHTTPResponse
			let httpRes = res as! NSHTTPURLResponse
			
			// Handle status codes
			self.delegate?.didReceiveAuthResults(withStatus: httpRes.statusCode)
		}
		
		task.resume()
	} // authenticate
	
	
	func loadAccounts() {
		let session = NSURLSession.sharedSession()
		let authURI = NSURL(string: baseAPI + "/accounts.php")
		
		// Create the request with Accept and Content-Type headers, POST method
		let req = NSMutableURLRequest(URL: authURI!)
		req.setValue("application/json", forHTTPHeaderField: "Accept")
		req.setValue("application/json", forHTTPHeaderField: "Content-Type")
		req.HTTPMethod = "GET"
		
		let task = session.dataTaskWithRequest(req) { (data, res, err) in
			// Handle connection errors
			if let error = err {
				NSLog(error.localizedDescription)
				self.delegate?.didEncounterAccountsError(error.localizedDescription)
				return
			}
			
			// Downcast NSURLResponse to NSHTTPResponse
			//let httpRes = res as! NSHTTPURLResponse
			self.delegate?.didLoadAccounts([])
		}
		task.resume()
	} // loadAccounts
	
}