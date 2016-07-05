//
//  CustomPointAnnotation.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/29/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
    var useCicle = false
    var accident:CrtAccident?
    private var cirle:UIImageView?
    private var superView: MKAnnotationView?
 
    func SetupView(superView: MKAnnotationView) {
        self.superView = superView
        SetMarkerImage()
        if useCicle {
            AnimateCicle()
        }
    }
    
    func AnimateCicle(animate: Bool=true, recreateCircle:Bool = false) {
        if animate {
            if recreateCircle {
                AnimateCicle(false)
            }
            if cirle == nil && superView != nil {
                cirle = UIImageView(image: CreateRedCircleImageOfSize(100))
                self.superView?.addSubview(cirle!)
                cirle!.centerInSuperView()
                cirle?.setScale(x: 0, y: 0)
                self.cirle!.alpha = 0.3

                UIView.animateWithDuration(3, delay:1, options: [.Repeat], animations: {
                    self.cirle!.setScale(x: 3, y: 3)
                    self.cirle!.alpha = 0
                }, completion: nil)
            }
        }else{
            if cirle != nil {
                self.cirle!.layer.removeAllAnimations()
                self.cirle!.removeFromSuperview()
                self.cirle = nil
            }
        }
    }
    
    func CreateRedCircleImageOfSize(size:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        let context = UIGraphicsGetCurrentContext()
        let rectangle = CGRect(x: 0, y: 0, width: size, height: size)
        
        CGContextSetFillColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetLineWidth(context, 0)
        
        CGContextAddEllipseInRect(context, rectangle)
        CGContextDrawPath(context, .FillStroke)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    func SetMarkerImage(name:String) {
        if superView == nil {
            return
        }
        let pinImage = UIImage(named:name)
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        pinImage!.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        superView!.image = resizedImage
    }
    func SetMarkerImage() {
        SetMarkerImage(self.imageName)
    }
}