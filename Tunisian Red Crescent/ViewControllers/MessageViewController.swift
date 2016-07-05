//
//  MessageViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/5/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import Kugel
import Alamofire
import AlamofireImage

final class MessageViewController : UIViewController {
    var message : CrtMessage?
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if message != nil {
            if !message!.Seen {
                message!.Save {
                    message!.Seen = true
                }
                Kugel.publish("OnMessage")
            }
            txtTitle.text = message!.Title
            txtDate.text = message!.SubmitDate?.toString()
            txtDescription.text = message!.Description
            if let imageUrl = message!.ImageFile {
                Notifications.BusyNavBar()
                Alamofire.request(.GET, imageUrl)
                    .responseImage { response in
                        Notifications.BusyNavBar(false)
                        if let image = response.result.value {
                            self.image.image = image
                        }
                }
            }
        }
    }

}