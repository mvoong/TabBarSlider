//
//  ExampleControl.swift
//  TabBarSliderDemo
//
//  Created by Michael Voong on 20/03/2015.
//  Copyright (c) 2015 Michael Voong. All rights reserved.
//

import Foundation
import MVTabBarSlider

public class ExampleControl: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var iconLabel: UILabel!
    
    override public var selected: Bool {
        didSet {
            updateState()
        }
    }
    
    override public var highlighted: Bool {
        didSet {
            updateState()
        }
    }
    
    func updateState() {
        if selected {
            backgroundImage.image = UIImage(named: "selected")
            label.textColor = UIColor.whiteColor()
        } else if highlighted {
            backgroundImage.image = UIImage(named: "highlighted")
            label.textColor = UIColor(red: 231 / 255.0, green: 118 / 255.0, blue: 115 / 255.0, alpha: 1)
        } else {
            backgroundImage.image = UIImage(named: "normal")
            label.textColor = UIColor(red: 231 / 255.0, green: 118 / 255.0, blue: 115 / 255.0, alpha: 1)
        }
        
        iconLabel.textColor = label.textColor
    }
}