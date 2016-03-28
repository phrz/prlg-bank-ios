//
//  LoginView.swift
//  Bank
//
//  Created by Paul Herz on 3/27/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation
import UIKit

class LoginView: UIView {
	override func drawRect(rect: CGRect) {
		let gradient = CAGradientLayer()
		gradient.frame = self.bounds
		
		let darkOrange = UIColor(red: 0.9569, green: 0.4196, blue: 0.2706, alpha: 1.0).CGColor
		let lightOrange = UIColor(red: 0.9333, green: 0.6588, blue: 0.2863, alpha: 1.0).CGColor
		
		gradient.colors = [darkOrange, lightOrange]
		self.layer.insertSublayer(gradient, atIndex: 0)
	}
}