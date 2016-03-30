//
//  AppDelegate.swift
//  Bank
//
//  Created by Paul Herz on 3/27/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

// Legal
//
// Icon Assets from https://icons8.com/license/ (Used under CC Attr-ND 3.0 U)

import UIKit

let authErrorNotification = "com.paulherz.authErrorNotificationKey"
let authResultsNotification = "com.paulherz.authResultsNotificationKey"

let accountsErrorNotification = "com.paulherz.accountsErrorNotificationKey"
let accountsLoadedNotification = "com.paulherz.accountsLoadedNotifcationKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BankAPIDelegate {

	var window: UIWindow?
	var api: BankAPI
	
	override init() {
		self.api = BankAPI()
		super.init()
		self.api.delegate = self
		
		Logger.sharedInstance.register(ConsoleLocation())
		Logger.sharedInstance.register(FileLocation())
	}
	
	func didEncounterAuthError(message: String) {
		NSLog("didEncounterAuthError: \(message)")
		NSNotificationCenter.defaultCenter().postNotificationName(
			authErrorNotification,
			object: self,
			userInfo: ["message": message]
		)
	}
	
	func didReceiveAuthResults(withStatus status: Int) {
		Logger.sharedInstance.log("didReceiveAuthResults: \(status)", sender: self)
		NSNotificationCenter.defaultCenter().postNotificationName(
			authResultsNotification,
			object: self,
			userInfo: ["status": status]
		)
	}
	
	func didEncounterAccountsError(message: String) {
		NSLog("didEncounterAccountsError: \(message)")
		NSNotificationCenter.defaultCenter().postNotificationName(
			accountsErrorNotification,
			object: self,
			userInfo: ["message": message]
		)
	}
	
	func didLoadAccounts() {
		NSLog("didLoadAccounts:")
		NSNotificationCenter.defaultCenter().postNotificationName(
			accountsLoadedNotification,
			object: self
		)
	}

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

