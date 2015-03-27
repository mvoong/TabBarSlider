//
//  ExampleControl.swift
//  TabBarSliderDemo
//
//  Created by Michael Voong on 20/03/2015.
//  Copyright (c) 2015 Michael Voong. All rights reserved.
//

import Foundation
import MVTabBarSlider

public class SimpleCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    public override func awakeFromNib() {
        label.alpha = 0.5
    }
    
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
            label.alpha = 1
        } else if highlighted {
            label.alpha = 0.8
        } else {
            label.alpha = 0.6
        }
    }
}