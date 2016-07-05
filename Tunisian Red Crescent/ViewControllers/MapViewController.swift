//
//  MapViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/30/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import SideMenu
import Kugel
import KCFloatingActionButton
import Spring
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON

final class MapViewController: UIViewController , MKMapViewDelegate{
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.delegate = self
        CrtMap.MapView = map
        
        Kugel.subscribe("OnLocation", block: {notification in
            CrtMap.UpdateUserMarker()
        })
        
        Settings.MainViewController = navigationController
        
        SetupSideMenu()
        
        SetupFloatingActionButton()
        
        Settings.InitializeApp()
        
        Notifications.BusyNavBar()
      
        //
        if UserSettings.autoConnect {
            if !UserSettings.username.isEmpty && !UserSettings.password.isEmpty {
                WebService.Authenticate(UserSettings.username, passwd: UserSettings.password, silent: true)
            }
            else if FBSDKAccessToken.currentAccessToken() != nil {
                WebService.FacebookAuthenticate(FBSDKAccessToken.currentAccessToken().tokenString, silent: true)
            }
        }
    }
    
    func SetupFloatingActionButton() {
        let fab = KCFloatingActionButton()
        fab.addItem("Where am i?", icon: UIImage(named: R.image.locationMapIcon.name)!, handler: { item in
            if CrtMap.userMarker != nil {
                CrtMap.ZoomPan(Location.lastLocation)
            }
            fab.close()
        })
        fab.buttonColor = UIColor.whiteColor()
        fab.plusColor = UIColor.redColor()
        self.view.addSubview(fab)
    }
    
    // MARK : Side Menu
    func SetupSideMenu() {
        SideMenuManager.menuAnimationBackgroundColor = UIColor(hex: "FFD6D6")
        SideMenuManager.menuAnimationFadeStrength = 0.1
        SideMenuManager.menuAnimationTransformScaleFactor = 0.9
        SideMenuManager.menuAllowPushOfSameClassTwice = false
        SideMenuManager.menuAllowPopIfPossible = true
        SideMenuManager.menuPresentMode = .MenuSlideIn
        SideMenuManager.menuShadowColor = UIColor.redColor()
        SideMenuManager.menuShadowOpacity = 0.5
        SideMenuManager.menuShadowRadius = 5
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.menuBlurEffectStyle = UIBlurEffectStyle.Light
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let cpa = annotation as? CustomPointAnnotation {
            let reuseId = "Marker"
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            else {
                anView!.annotation = annotation
            }
            anView!.canShowCallout = cpa.accident == nil

            cpa.SetupView(anView!)
            return anView
        }
        return nil
    }
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let cpa = view.annotation as? CustomPointAnnotation {
            if let acc = cpa.accident {
                if let accident = Accidents[acc.id!] {
                    let sa = SweetAlert()
                    if accident.Image != nil {
                        sa.imageView = UIImageView(image:(accident.Image))
                        sa.kAnimatedViewHeight = 250
                        sa.imageView?.contentMode = .ScaleAspectFit
                    }else{
                        sa.imageView = UIImageView(image: UIImage(named:(accident.IsHandled ? R.image.accidentOk.name : R.image.accident.name)))
                    }
                    
                    let text = accident.Description! + "\n\n" + accident.Location!.Timestamp!.timePassed()
                    if accident.IsHandled {
                        sa.showAlert("Handled Accident", subTitle: text, style: AlertStyle.None, buttonTitle:"Close", buttonColor:UIColorFromRGB(0xD0D0D0))
                    }else{
                        sa.showAlert("Handle Accident?", subTitle: text, style: AlertStyle.None, buttonTitle:"Cancel", buttonColor:UIColorFromRGB(0xD0D0D0) , otherButtonTitle:  "Handle!", otherButtonColor: UIColorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
                            if isOtherButton == true {
                                print("Cancel Button  Pressed")
                            }
                            else {
                                WebService.HandleAccident(accident.id!)
                            }
                        }
                    }
                    
                }
            }
            
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Since swift kills the animated circle when it's not visible, we're gonna recreate it when we're back.
        for (_,accident) in Accidents {
            if accident.marker != nil {
                CrtMap.UpdateAccidentMarker(accident, recreateCircle: true)
            }
        }
    }
}