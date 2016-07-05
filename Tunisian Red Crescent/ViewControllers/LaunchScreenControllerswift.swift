//
//  LaunchScreenControllerswift.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/30/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import UIKit
import EZSwiftExtensions
import Spring
final class LaunchScreenController: UIViewController {
    @IBOutlet weak var logo: SpringImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //prepare
        let storyboard = GrabStoryBoard()
        let viewcontroller = storyboard.instantiateInitialViewController()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        
        self.logo.animation = "pop"
        self.logo.duration = 1
        self.logo.force = 1.5
        self.logo.damping = 0.7
        self.logo.velocity = 0.7
        self.logo.curve = "easeIn"

        logo.animateToNext({
            self.logo.animation = "zoomOut"
            self.logo.duration = 2
            self.logo.force = 1.5
            self.logo.damping = 0.7
            self.logo.velocity = 0.7
            self.logo.curve = "easeOut"

            self.logo.animateToNext({
                //Go!
                appDelegate.window?.rootViewController = viewcontroller
            })
        })
    }
    
    func GrabStoryBoard() -> UIStoryboard {
        //TODO: ScreenSize -> UIStoryboard
        let screenHeight = ez.screenHeight
        switch (screenHeight)
        {
        // iPhone 4s
        case 480:
            print("Switching to iPhone 4s")
            return UIStoryboard(name: R.storyboard.main35.name, bundle: nil)
        // iPhone 5s
        case 568:
            print("Switching to iPhone 5s")
            return UIStoryboard(name: R.storyboard.main4.name, bundle: nil)
        // iPhone 6
        case 667:
            print("Switching to iPhone 6")
            return UIStoryboard(name: R.storyboard.main47.name, bundle: nil)
        // iPhone 6 Plus
        case 736:
            print("Switching to iPhone 6 Plus")
            return UIStoryboard(name: R.storyboard.main55.name, bundle: nil)
        default:
            print("Switching to iPhone default")
            return UIStoryboard(name: R.storyboard.main55.name, bundle: nil)
        }
    }
}