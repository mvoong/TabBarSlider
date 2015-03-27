//
//  Control.swift
//  TabBarSliderDemo
//
//  Created by Michael Voong on 20/03/2015.
//  Copyright (c) 2015 Michael Voong. All rights reserved.
//

import Foundation

public class Control: UIView {
    public enum ControlState {
        case Normal
        case Highlighted
        case Selected
    }
    
    public var state = ControlState.Normal
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = false
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        userInteractionEnabled = false
    }
}