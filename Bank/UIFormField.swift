//
//  UIFormField.swift
//  Bank
//
//  Created by Paul Herz on 3/27/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation
import UIKit

// A solution for a form field to reference the next field
// that the Next button should go to based on answer
// [CITE] http://stackoverflow.com/a/5889795/3592716

class UIFormField: UITextField {
	@IBOutlet weak var nextField: UITextField?
}