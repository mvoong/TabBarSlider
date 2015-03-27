//
//  ViewController.swift
//  TabBarSliderDemo
//
//  Created by Michael Voong on 20/03/2015.
//  Copyright (c) 2015 Michael Voong. All rights reserved.
//

import UIKit
import MVTabBarSlider

class ViewController: UIViewController {
    struct Item {
        let icon: String
        let label: String
    }
    
    lazy var items = [
        Item(icon: "", label: "Music"),
        Item(icon: "", label: "Wi-Fi"),
        Item(icon: "", label: "Camera"),
        Item(icon: "", label: "LinkedIn"),
        Item(icon: "", label: "Settings"),
        Item(icon: "", label: "Transport"),
        Item(icon: "", label: "Music"),
        Item(icon: "", label: "RSS"),
        Item(icon: "", label: "Bus"),
        Item(icon: "", label: "Chat")
    ]
    
    @IBOutlet weak var slider: TabBarSlider!
    @IBOutlet weak var slider2: TabBarSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.cellNib = UINib(nibName: "ExampleControl", bundle: nil)
        slider.delegate = self
        slider.dataSource = self
        slider.itemWidth = 70
        
        slider2.cellNib = UINib(nibName: "SimpleCell", bundle: nil)
        slider2.delegate = self
        slider2.dataSource = self
        slider2.estimatedItemWidth = 64
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

extension ViewController: TabBarSliderDelegate {
    func tabBarSliderDidSelectItem(item: Int) {
        println("Selected item: \(item)")
    }
    
    func tabBarSliderIndicatorView(slider: TabBarSlider) -> UIView {
        if slider == self.slider2 {
            let nib = UINib(nibName: "DotIndicator", bundle: nil)
            return nib.instantiateWithOwner(nil, options: nil).first as UIView
        }
        
        let nib = UINib(nibName: "ExampleIndicator", bundle: nil)
        return nib.instantiateWithOwner(nil, options: nil).first as UIView
    }
}

extension ViewController: TabBarSliderDataSource {
    func tabBarSliderNumberOfItems(slider: TabBarSlider) -> Int {
        return items.count
    }
    
    func tabBarSlider(slider: TabBarSlider, configureCell: UICollectionViewCell, forItem: Int) {
        if let cell = configureCell as? ExampleControl {
            cell.label.text = items[forItem].label
            cell.iconLabel.text = items[forItem].icon
        } else if let cell = configureCell as? SimpleCell {
            cell.label.text = items[forItem].label
        }
    }
}