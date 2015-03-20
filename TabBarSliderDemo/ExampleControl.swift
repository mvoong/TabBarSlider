//
//  ExampleControl.swift
//  TabBarSliderDemo
//
//  Created by Michael Voong on 20/03/2015.
//  Copyright (c) 2015 Michael Voong. All rights reserved.
//

import Foundation
import MVTabBarSlider

public class ExampleControl: Control {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var iconLabel: UILabel!
    
    override public var state: ControlState {
        didSet {
            switch state {
            case .Normal:
                backgroundImage.image = UIImage(named: "normal")
                label.textColor = UIColor(red: 231 / 255.0, green: 118 / 255.0, blue: 115 / 255.0, alpha: 1)
            case .Highlighted:
                backgroundImage.image = UIImage(named: "highlighted")
                label.textColor = UIColor(red: 231 / 255.0, green: 118 / 255.0, blue: 115 / 255.0, alpha: 1)
            case .Selected:
                backgroundImage.image = UIImage(named: "selected")
                label.textColor = UIColor.whiteColor()
            }
            
            iconLabel.textColor = label.textColor
        }
        
    }
}