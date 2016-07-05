//
//  AboutViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/11/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import EZSwiftExtensions
final class AboutViewController : UIViewController{
  
    @IBOutlet weak var versionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = "Version : " + ez.appVersion!
    }
    
}