//
//  TabBarSlider.swift
//  TabBarSlider
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
    func tabBarSlider(slider: TabBarSlider, configureCell: UICollectionViewCell, forItem: Int)
}

public class TabBarSlider: UIView {
    public typealias UpdateOperations = Void -> Void
    
    public var dataSource: TabBarSliderDataSource?
    public var delegate: TabBarSliderDelegate?
    public var cellNib: UINib? {
        didSet {
            collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "Cell")
        }
    }
    
    /**
    A fixed item width. Use estimatedItemWidth if your cells are of variable width.
    */
    public var itemWidth: CGFloat = 64 {
        didSet {
            if itemWidth != oldValue {
                collectionView.performBatchUpdates(nil, completion: nil)
                if selectedIndex != nil {
                    setActiveIndex(selectedIndex!, animated: false, moveToNaturalScrollPosition: true, wobble: false)
                }
            }
        }
    }
    
    /**
    The estimated width of the items, used to help lay out the scrollview. The default value of this property is 0. Setting it to any other 
    value causes the tab bar slider to query each cell for its actual size using the cell’s preferredLayoutAttributesFittingAttributes: method. 
    If all of your cells are the same width, use the itemWidth property, instead of this property, to specify the cell size instead. 
    
    See -[UICollectionViewFlowLayout estimatedItemSize]
    */
    public var estimatedItemWidth: CGFloat = 0 {
        didSet {
            if estimatedItemWidth != oldValue {
                let size = estimatedItemWidth != 0 ? CGSizeMake(estimatedItemWidth, self.frame.height) : CGSizeZero
                (collectionView.collectionViewLayout as UICollectionViewFlowLayout).estimatedItemSize = size
            }
        }
    }
    
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    var indicatorView: UIView?
    
    var selectedIndex: Int?
    var reportedIndex: Int?
    var indexTracker: IndexTracker?
    var isLayouting: Bool = false
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        sharedInit()
    }
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    func sharedInit() {
        collectionView.backgroundColor = UIColor.clearColor()
        (collectionView.collectionViewLayout as UICollectionViewFlowLayout).scrollDirection = .Horizontal
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(true)
        collectionView.frame = bounds
        collectionView.autoresizingMask = .None
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.allowsMultipleSelection = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        addSubview(collectionView)
    }
    
    /**
    Reloads an item with animation. The delegate will be asked to reconfigure the cell.
    
    :param: index The index of the item to be reloaded
    */
    public func reloadItem(index: Int) {
        collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
    }
    
    /**
    Deletes an item.
    
    :param: index The index of the item to delete
    */
    public func deleteItem(index: Int) {
        let indexTracker = self.indexTracker ?? IndexTracker(itemCount: collectionView.numberOfItemsInSection(0))
        collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
        indexTracker.delete(index)
        let result = indexTracker.followIndex(index)
        
        if self.indexTracker == nil && selectedIndex != nil {
            if result.isAlternative == true {
                selectedIndex = result.index
                collectionView.selectItemAtIndexPath(NSIndexPath(forItem: selectedIndex!, inSection: 0), animated: false, scrollPosition: .None)
                setActiveIndex(result.index!, animated: true, moveToNaturalScrollPosition: true, wobble: false)
                delegate?.tabBarSliderDidSelectItem(selectedIndex!)
            }
        }
    }

    /**
    Inserts an item with animation
    
    :param: index The index where the item has been inserted
    */
    public func insertItem(index: Int) {
        let indexTracker = self.indexTracker ?? IndexTracker(itemCount: collectionView.numberOfItemsInSection(0))
        collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
        indexTracker.insert(index)
        
        if self.indexTracker == nil && selectedIndex != nil {
            var result = indexTracker.followIndex(selectedIndex!)
            selectedIndex = result.index
            setActiveIndex(selectedIndex!, animated: true, moveToNaturalScrollPosition: true, wobble: false)
        }
    }
    
    /**
    Moves an item with animation
    
    :param: fromIndex The old index
    :param: toIndex The new index
    */
    public func moveItem(#fromIndex: Int, toIndex: Int) {
        let indexTracker = self.indexTracker ?? IndexTracker(itemCount: collectionView.numberOfItemsInSection(0))
        collectionView.moveItemAtIndexPath(NSIndexPath(forItem: fromIndex, inSection: 0), toIndexPath: NSIndexPath(forItem: toIndex, inSection: 0))
        indexTracker.move(fromIndex, toIndex: toIndex)
        
        if self.indexTracker == nil && selectedIndex != nil {
            var result = indexTracker.followIndex(selectedIndex!)
            selectedIndex = result.index
            println("New selected index: \(selectedIndex!)")
            setActiveIndex(selectedIndex!, animated: true, moveToNaturalScrollPosition: true, wobble: false)
        }
    }
    
    /**
    Apply a series of delete, insert and move operations in a single animation.

    :param: operations A closure performing one or more update, remove, insert or move operations. See reloadItem:, deleteItem:, insertItem: and moveItem:.
    */
    public func reloadItems(operations: UpdateOperations) {
        indexTracker = IndexTracker(itemCount: self.collectionView.numberOfItemsInSection(0))
        
        collectionView.performBatchUpdates(operations, completion: nil)
        if selectedIndex != nil {
            var result = indexTracker!.followIndex(selectedIndex!)
            selectedIndex = result.index!

            if result.isAlternative == true {
                collectionView.selectItemAtIndexPath(NSIndexPath(forItem: selectedIndex!, inSection: 0), animated: false, scrollPosition: .None)
                delegate?.tabBarSliderDidSelectItem(selectedIndex!)
            }
            
            setActiveIndex(selectedIndex!, animated: true, moveToNaturalScrollPosition: true, wobble: false)
        }
        
        indexTracker = nil
    }
    
    public func selectItem(index: Int, animated: Bool = false) {
        selectedIndex = index
        collectionView.layoutIfNeeded() // Force items to be ready
        clearSelectionsExcept(index)
        collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: .None)
        setActiveIndex(index, animated: animated, moveToNaturalScrollPosition: true, wobble: animated)
    }

    public func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: Collection view delegate

extension TabBarSlider: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        dataSource?.tabBarSlider(self, configureCell: cell, forItem: indexPath.item)
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.tabBarSliderNumberOfItems(self) ?? 0
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource == nil ? 0 : 1
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item != selectedIndex {
            selectedIndex = indexPath.item
            reportedIndex = indexPath.item
            
            setActiveIndex(indexPath.item, animated: true, moveToNaturalScrollPosition: true, wobble: true)
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: indexPath.item, inSection: 0), animated: false, scrollPosition: .None)
            clearSelectionsExcept(indexPath.item)
            delegate?.tabBarSliderDidSelectItem(indexPath.item)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Don't allow a collection view with no selections
        return collectionView.indexPathsForSelectedItems().count > 1
    }
    
    func clearSelectionsExcept(index: Int) {
        for selectedIndexPath in collectionView.indexPathsForSelectedItems() {
            let selectedIndexPath = selectedIndexPath as NSIndexPath
            if index != selectedIndexPath.item {
                collectionView.deselectItemAtIndexPath(selectedIndexPath, animated: true)
            }
        }
    }
}

// MARK: Flow Layout Delegate

extension TabBarSlider: UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(itemWidth, collectionView.frame.height)
    }
}

// MARK: Animations

extension TabBarSlider {
    func setActiveIndex(index: Int, animated: Bool, moveToNaturalScrollPosition: Bool, wobble: Bool) {
        let animation: Void -> Void = {
            if (moveToNaturalScrollPosition) {
                self.collectionView.contentOffset = CGPointMake(self.targetOffsetForItem(index), 0)
            }
            self.layoutIndicatorView()
            UIView.performWithoutAnimation({ () -> Void in
                self.collectionView.layoutIfNeeded()
            })
        }

        if animated {
            if wobble {
                UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .AllowUserInteraction, animations: { () -> Void in
                    animation()
                }, completion: nil)
            } else {
                UIView.animateWithDuration(0.3, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
                    animation()
                }, completion: nil)
            }
        } else {
            animation()
        }
    }

    func layoutIndicatorView() {
        if let selectedIndex = selectedIndex {
            if let delegate = delegate {
                if indicatorView == nil && delegate.respondsToSelector("tabBarSliderIndicatorView:") {
                    indicatorView = delegate.tabBarSliderIndicatorView(self)
                    indicatorView?.autoresizingMask = UIViewAutoresizing.None
                    indicatorView?.setTranslatesAutoresizingMaskIntoConstraints(true)
                }
            }
            
            if let indicatorView = indicatorView {
                if indicatorView.superview == nil {
                    collectionView.addSubview(indicatorView)
                }
                let selectedCellFrame = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: selectedIndex, inSection: 0)).frame
                indicatorView.frame = selectedCellFrame
            }
        }
    }
}

// MARK: Scroll view

extension TabBarSlider: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isLayouting {
            let index = naturalIndexForContentOffset(scrollView.contentOffset.x)
            if selectedIndex != index {
                selectedIndex = index
                collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: .None)
                clearSelectionsExcept(index)
                setActiveIndex(index, animated: true, moveToNaturalScrollPosition: false, wobble: false)
            }
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
    
    public override func layoutSubviews() {
        // Don't automatically select items while layouting (e.g. while rotating)
        isLayouting = true
        super.layoutSubviews()
        collectionView.frame = bounds
        if selectedIndex != nil {
            setActiveIndex(selectedIndex!, animated: false, moveToNaturalScrollPosition: true, wobble: false)
        }
        isLayouting = false
    }
}

// MARK: Calculations

extension TabBarSlider {
    /**
    Given a scroll position, calculates the index of the item that should be selected.

    :param: offset The current scroll offset
    :returns: The index path that should be selected
    */
    func naturalIndexForContentOffset(offset: CGFloat) -> Int {
        let scrollableWidth = collectionView.contentSize.width - bounds.width
        if offset <= 0 {
            return 0
        } else if offset >= scrollableWidth {
            return collectionView.numberOfItemsInSection(0) - 1
        }
        
        var offsetRatio = offset / scrollableWidth
        offsetRatio = max(0, min(scrollableWidth, offsetRatio))
        let targetOffsetInScrollView = offsetRatio * collectionView.contentSize.width
        
        return collectionView.indexPathForItemAtPoint(CGPointMake(targetOffsetInScrollView, 0))?.item ?? 0
    }
    
    /**
    Given an index, calculates the required scroll position that would result in the item being in its natural position
    
    :param: index The index of the item
    :returns: The scroll offset
    */
    func targetOffsetForItem(index: Int) -> CGFloat {
        let frame = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)).frame
        let offsetRatio = frame.minX / (collectionView.contentSize.width - frame.width)
        var scrollableWidth = collectionView.contentSize.width - bounds.width
        
        // Handle case where all buttons fit without scrolling
        scrollableWidth = max(0, scrollableWidth)
        
        return offsetRatio * scrollableWidth
    }
}

class IndexTracker {
    enum OperationType: Int {
        case Delete = 0
        case Insert = 1
        case Move = 2
    }
    
    typealias Operation = (type: OperationType, firstIndex: Int, lastIndex: Int?)
    
    var operations = [Operation]()
    var itemCount: Int
    
    init(itemCount: Int) {
        self.itemCount = itemCount;
    }
    
    func delete(index: Int) {
        operations.append((.Delete, index, nil))
    }
    
    func insert(index: Int) {
        operations.append((.Insert, index, nil))
    }
    
    func move(fromIndex: Int, toIndex: Int) {
        operations.append((.Move, fromIndex, toIndex))
    }
    
    /**
    Follows an index through a series of delete, insert and move operations.
    
    :param: index: The index of the item to follow
    :returns: A tuple representing the resulting index, and whether an alternative item has been given. The resulting index
        may be nil if the item has been deleted, and there is no alternative to select. The isAlternative value will be set
        to true if the next closest index has been returned.
    */
    func followIndex(index: Int) -> (index: Int?, isAlternative: Bool?) {
        var newIndex = index
        let deleteOperations = operations.filter { $0.type == .Delete }
        let isAlternative = (deleteOperations.filter { $0.firstIndex == index }).count > 0
        for deleteOperation in deleteOperations {
            itemCount--
            
            if itemCount == 0 {
                return (nil, nil)
            }
            
            if deleteOperation.firstIndex <= index {
                newIndex--
            }
            newIndex = max(0, min(index, itemCount - 1))
        }
        
        let insertOperations = operations.filter { $0.type == .Insert }
        for insertOperation in insertOperations {
            itemCount++
            if insertOperation.firstIndex <= index {
                newIndex++
            }
        }

        let moveOperations = operations.filter { $0.type == .Move }
        for moveOperation in moveOperations {
            if index == moveOperation.firstIndex {
                newIndex = moveOperation.lastIndex!
            } else if moveOperation.firstIndex > index && moveOperation.lastIndex <= index {
                newIndex++
            } else if moveOperation.firstIndex <= index && moveOperation.lastIndex >= index {
                newIndex = newIndex - 1
            }
        }
        
        return (newIndex, isAlternative)
    }
}