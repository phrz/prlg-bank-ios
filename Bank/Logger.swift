//
//  Logger.swift
//  Bank
//
//  Created by Paul Herz on 3/29/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

enum LoggerItemLevel: String {
	case Error = "[ERR]",
	Warning = "[WARN]",
	Info = "[INFO]"
}

protocol LoggerItemProtocol {
	var level: LoggerItemLevel { get }
	var message: String? { get }
	var sender: AnyObject? { get }
	func description() -> String
}

protocol LoggerLocationProtocol {
	init(verbose: Bool)
	func logTo(itemContent: String)
}

struct LoggerItem: LoggerItemProtocol {
	let level: LoggerItemLevel
	let message: String?
	let sender: AnyObject?
	
	func description() -> String {
		var tempDesc = "\(level.rawValue)"
		
		if (sender != nil) {
			let senderMirror = Mirror(reflecting: sender!)
			tempDesc += " [\(senderMirror.subjectType)]"
		}
		
		if (message != nil) {
			tempDesc += " \(message!)"
		}
		
		tempDesc += "\n"
		
		return tempDesc
	}
}

class ConsoleLocation: LoggerLocationProtocol {
	var verbose: Bool
	
	required init(verbose: Bool) {
		self.verbose = verbose
		if(self.verbose) {
			print("[LOGGER] Now logging to console...")
		}
	}
	
	func logTo(itemContent: String) {
		print(itemContent)
	}
}

class FileLocation: LoggerLocationProtocol {
	
	var logFilePath: String
	var verbose: Bool
	
	// Defer file handle establishment until first use (lazy)
	lazy var logFileHandle: NSFileHandle? = {
		let logFileHandle = NSFileHandle.init(forWritingAtPath: self.logFilePath)
		return logFileHandle
	}()
	
	required init(verbose: Bool) {
		// Set verbose flag
		self.verbose = verbose
		
		if(self.verbose) {
			print("[LOGGER] logger set to verbose, will log metadata to console")
		}
		// Generate the file path
		let dir: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
		self.logFilePath = dir.stringByAppendingPathComponent("log.txt")
		// Create logfile if it doesn't exist
		if(!NSFileManager.defaultManager().fileExistsAtPath(logFilePath)) {
			if(self.verbose) {
				print("[LOGGER] creating log file")
			}
			NSFileManager.defaultManager().createFileAtPath(logFilePath, contents: nil, attributes: nil)
		}
		// Print log file path if verbose
		if(self.verbose) {
			print("[LOGGER] Now logging to file (\(self.logFilePath))")
		}
	}
	
	func logTo(itemContent: String) {
		if let logFileHandle = logFileHandle {
			let data = itemContent.dataUsingEncoding(NSUTF8StringEncoding)
			logFileHandle.seekToEndOfFile()
			logFileHandle.writeData(data!)
		}
	}
	
	deinit {
		logFileHandle?.closeFile()
	}
}

class Logger {
	// Singleton (shared instance)
	static let sharedInstance = Logger()
	static let loggerIdentifier = "com.paulherz.Bank.Logger"
	
	private var locations = [LoggerLocationProtocol]()
	internal var verbose: Bool = false
	
	// add a location to the locations array
	func register(location: LoggerLocationProtocol.Type) {
		locations.append(location.init(verbose: self.verbose))
	}
	
	// Instantiate the queue only upon first use
	lazy var messageQueue: NSOperationQueue = {
		let mq = NSOperationQueue()
		// Set the QoS to Background so as to not delay the UI
		// or the user-engaged services
		mq.qualityOfService = NSQualityOfService.Background
		// Require a max of 1 logging operation to ensure predictable
		// log order
		mq.maxConcurrentOperationCount = 1
		// Uniquely identify the queue
		mq.name = Logger.loggerIdentifier
		return mq
	}()
	
	// Enqueue a message into the log queue
	func log(item: LoggerItemProtocol) {
		self.messageQueue.addOperationWithBlock {
			for location in self.locations {
				location.logTo(item.description())
			}
		}
	}
	
	func log(message: String, sender: AnyObject?, level: LoggerItemLevel = .Info) {
		let item = LoggerItem(level: level, message: message, sender: sender)
		self.log(item)
	}
}