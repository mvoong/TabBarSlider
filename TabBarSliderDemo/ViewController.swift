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
        Item(icon: "", label: "Chat"),
        Item(icon: "", label: "Music"),
        Item(icon: "", label: "RSS"),
        Item(icon: "", label: "Camera"),
        Item(icon: "", label: "LinkedIn"),
        Item(icon: "", label: "Settings"),
        Item(icon: "", label: "Bus"),
        Item(icon: "", label: "Chat")
    ]
    
    @IBOutlet weak var slider: TabBarSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.cellNib = UINib(nibName: "ExampleControl", bundle: nil)
        slider.delegate = self
        slider.dataSource = self
    }
}

extension ViewController: TabBarSliderDelegate {
    func tabBarSliderDidSelectItem(item: Int) {
        println("Found: \(item)")
    }
    
    func tabBarSliderIndicatorView(slider: TabBarSlider) -> UIView {
        let nib = UINib(nibName: "ExampleIndicator", bundle: nil)
        return nib.instantiateWithOwner(nil, options: nil).first as UIView
    }
}

extension ViewController: TabBarSliderDataSource {
    func tabBarSliderNumberOfItems(slider: TabBarSlider) -> Int {
        return items.count
    }
    
    func tabBarSlider(slider: TabBarSlider, configureCell: UICollectionViewCell, forItem: Int) {
        let cell = configureCell as ExampleControl
        cell.label.text = items[forItem].label
        cell.iconLabel.text = items[forItem].icon
    }
}