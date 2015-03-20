//
//  TabBarSlider.swift
//  TabBarSliderDemo
//
//  Created by Michael Voong on 20/03/2015.
//  Copyright (c) 2015 Michael Voong. All rights reserved.
//

import UIKit
import PureLayout

public protocol TabBarSliderDelegate: UIScrollViewDelegate {
    func tabBarSliderDidSelectItem(item: Int)
    func tabBarSliderIndicatorView(slider: TabBarSlider) -> UIView
}

public protocol TabBarSliderDataSource {
    func tabBarSliderNumberOfItems(slider: TabBarSlider) -> Int
    func tabBarSlider(slider: TabBarSlider, controlForItem: Int) -> Control
    func tabBarSlider(slider: TabBarSlider, configureControl: Control, forItem: Int)
}

class WrapperControl: UIControl {
    var control: Control?
    
    init(view: Control) {
        super.init(frame: CGRectZero)
        
        control = view;
        setTranslatesAutoresizingMaskIntoConstraints(false)
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(view)
        view.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var selected: Bool {
        didSet {
            updateState()
        }
    }
    
    override var highlighted: Bool {
        didSet {
            updateState()
        }
    }
    
    func updateState() {
        if highlighted {
            control?.state = .Highlighted
        } else if selected {
            control?.state = .Selected
        } else {
            control?.state = .Normal
        }
    }
}

public class TabBarSlider: UIView {
    public var dataSource: TabBarSliderDataSource?
    public var delegate: TabBarSliderDelegate?
    public typealias UpdateOperations = Void -> Void
    let scrollView = TabBarScrollView()
    var indicatorView: UIView?
    var indicatorConstraints = [NSLayoutConstraint]()
    var controls = [WrapperControl]()
    
    var selectedIndex: Int?
    var reportedIndex: Int?
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layoutMargins = UIEdgeInsetsZero
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    public func insertItem(index: Int) {
        
    }
    
    public func updateItem(index: Int) {
        
    }
    
    public func moveItem(#fromIndex: Int, toIndex: Int) {
        
    }
    
    public func removeItem(index: Int) {
        
    }
    
    public func updateItems(operations: UpdateOperations) {
        
    }
    
    public func reloadData() {
        if let dataSource = dataSource {
            let itemCount = dataSource.tabBarSliderNumberOfItems(self)
            for index in 0..<itemCount {
                let control = dataSource.tabBarSlider(self, controlForItem: index)

                let wrapper = WrapperControl(view: control)
                wrapper.addSubview(control)
                wrapper.addTarget(self, action: "pressControl:", forControlEvents: UIControlEvents.TouchUpInside)
                
                controls.append(wrapper)
                scrollView.addSubview(wrapper)
            }
            addControlConstraints()
            layoutIfNeeded()
            
            if let first = controls.first {
                self.pressControl(first)
            }
        }
    }
    
    func addControlConstraints() {
        var previousControl: UIView?
        for control in controls {
            // Vertical constraint
            control.autoPinEdgeToSuperviewEdge(.Top)
            control.autoPinEdgeToSuperviewEdge(.Bottom)
            control.autoMatchDimension(.Height, toDimension: .Height, ofView: scrollView)
            
            // Left constraint
            if let previousControl = previousControl {
                control.autoConstrainAttribute(.Left, toAttribute: .Right, ofView: previousControl)
            } else {
                control.autoPinEdgeToSuperviewEdge(.Left)
            }
            
            // Right constraint
            if control == controls.last {
                control.autoPinEdgeToSuperviewEdge(.Right)
            }
            
            previousControl = control
        }
    }
    
    func selectControlAtIndex(selectedIndex: Int) {
        for (index, control) in enumerate(controls) {
            control.selected = index == selectedIndex
        }
    }
    
    func pressControl(selectedControl: WrapperControl) {
        if let index = find(controls, selectedControl) {
            if index != selectedIndex {
                let firstSelection = selectedIndex == nil
                selectedIndex = index
                reportedIndex = index
                
                setActiveIndex(index, animated: !firstSelection, moveToNaturalScrollPosition: !firstSelection, wobble: !firstSelection)
                selectControlAtIndex(index)
                delegate?.tabBarSliderDidSelectItem(index)
            }
        }
    }
}

// Animations
extension TabBarSlider {
    func setActiveIndex(index: Int, animated: Bool, moveToNaturalScrollPosition: Bool, wobble: Bool) {
        let animation: Void -> Void = {
            if (moveToNaturalScrollPosition) {
                self.scrollView.contentOffset = CGPointMake(self.targetOffsetForItem(index), 0)
            }
            self.layoutIndicatorView()
        }
        
        if animated {
            if wobble {
                UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .AllowUserInteraction, animations: { () -> Void in
                    animation()
                }, completion: nil)
            } else {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    animation()
                })
            }
        } else {
            animation()
        }
    }
    
    func layoutIndicatorView() {
        if let selectedIndex = selectedIndex {
            let control = controls[selectedIndex]
            
            if let delegate = delegate {
                if indicatorView == nil && delegate.respondsToSelector("tabBarSliderIndicatorView:") {
                    indicatorView = delegate.tabBarSliderIndicatorView(self)
                }
            }
            
            if let indicatorView = indicatorView {
                if indicatorView.superview == nil {
                    scrollView.addSubview(indicatorView)
                }

                indicatorView.frame = control.frame
            }
        }
    }
}

// Scroll view
extension TabBarSlider: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let index = naturalIndexForContentOffset(scrollView.contentOffset.x)
        if selectedIndex != index {
            selectedIndex = index
            selectControlAtIndex(index)
            setActiveIndex(index, animated: true, moveToNaturalScrollPosition: false, wobble: false)
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if reportedIndex != selectedIndex {
                reportedIndex = selectedIndex
                delegate?.tabBarSliderDidSelectItem(selectedIndex!)
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if reportedIndex != selectedIndex {
            reportedIndex = selectedIndex
            delegate?.tabBarSliderDidSelectItem(selectedIndex!)
        }
    }
}

// Calculations
extension TabBarSlider {
    func naturalIndexForContentOffset(offset: CGFloat) -> Int {
        let scrollableWidth = scrollView.contentSize.width - bounds.width
        var offsetRatio = offset / scrollableWidth
        offsetRatio = max(0, min(scrollableWidth, offsetRatio))
        
        let targetOffsetInScrollView = offsetRatio * scrollView.contentSize.width
        let index = indexForPosition(targetOffsetInScrollView)
        
        return index
    }
    
    func indexForPosition(position: CGFloat) -> Int {
        if position < 0 {
            return 0
        }
        if position > scrollView.contentSize.width {
            return controls.count - 1
        }
        for (index, control) in enumerate(controls) {
            if control.frame.minX <= position && position <= control.frame.maxX {
                return index
            }
        }
        return 0
    }
    
    func targetOffsetForItem(index: Int) -> CGFloat {
        let frame = controls[index].frame
        let offsetRatio = frame.minX / (scrollView.contentSize.width - frame.width)
        let scrollableWidth = scrollView.contentSize.width - bounds.width
        
        return offsetRatio * scrollableWidth
    }
}

class TabBarScrollView: UIScrollView
{
    override func touchesShouldCancelInContentView(view: UIView!) -> Bool {
        return true
    }
}
