//
//  BankAPIHandler.swift
//  Bank
//
//  Created by Paul Herz on 3/27/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

class BankAPIHandler {
	
	func authenticate(username userOpt: String?, password passOpt: String?) -> Bool {
		print("Dummy auth routine")
		
		guard let username = userOpt else {
			return false
		}
		
		guard let password = passOpt else {
			return false
		}
		
		print("\(username), \(password)")
		
		return true
	}
}