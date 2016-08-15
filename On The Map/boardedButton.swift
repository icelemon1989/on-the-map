//
//  boardedButton.swift
//  On The Map
//
//  Created by Yang Ji on 8/15/16.
// Follow the instruction and copy from Jarrod Parkes @Udacity
//  Copyright © 2016 Yang Ji. All rights reserved.
//


import UIKit


@IBDesignable
class boardedButton: UIButton {
    
    // MARK: IBInspectable
    @IBInspectable var backingColor: UIColor = UIColor.clearColor() {
        didSet {
            backgroundColor = backingColor
        }
    }
    
    @IBInspectable var highlightColor: UIColor = UIColor.clearColor() {
        didSet {
            if state == .Highlighted {
                backgroundColor = highlightColor
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            layer.masksToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }
    
    //MARK: Tracking
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        backgroundColor = highlightColor
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        backgroundColor = backingColor
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        backgroundColor = backingColor
    }
}
