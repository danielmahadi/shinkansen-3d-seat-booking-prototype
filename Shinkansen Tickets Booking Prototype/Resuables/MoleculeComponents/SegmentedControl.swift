//
//  SegmentedControl.swift
//  Shinkansen Tickets Booking Prototype
//
//  Created by Virakri Jinangkul on 6/10/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit

class SegmentedControl: UIControl {
    
    var stackView: UIStackView
    
    static let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private var _selectedIndex: Int = 0
    
    var selectedIndex: Int {
        get {
            return _selectedIndex
        }set{
            if selectedIndex != newValue {
                SegmentedControl.feedbackGenerator.impactOccurred()
                _selectedIndex = newValue
            }
            setSelectedIndexItemCardControlSelected()
        }
    }
    
    var items: [(title: String, subtitle: String, isEnabled: Bool)]? {
        didSet {
            setupItems()
            setSelectedIndexItemCardControlSelected()
        }
    }
    
    var segmentedItemControls: [SegmentedItemControl]
    
    init(items: [(title: String, subtitle: String, isEnabled: Bool)]? = nil) {
        stackView = UIStackView()
        segmentedItemControls = []
        super.init(frame: .zero)
        self.items = items
        setupView()
        setSelectedIndexItemCardControlSelected()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        directionalLayoutMargins = DesignSystem.layoutMargins.segmentedControl()
        addSubview(stackView, withConstaintEquals: .marginEdges)
        
        stackView.distribution = .fillEqually
        stackView.spacing = DesignSystem.spacing.cardGutter
        stackView.isUserInteractionEnabled = false
        
        segmentedItemControls = []
        
        // Setup Items
        setupItems()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        var isTouchOnItemCards = false
        segmentedItemControls.forEach { (segmentedItemControl) in
            if segmentedItemControl.bounds.contains(touch.location(in: segmentedItemControl)) {
                isTouchOnItemCards = true
                segmentedItemControl.isHighlighted = true
            }
        }
        return isTouchOnItemCards
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        segmentedItemControls.forEach { (segmentedItemControl) in
            segmentedItemControl.isHighlighted = segmentedItemControl.bounds.contains(touch.location(in: segmentedItemControl))
        }
        return bounds.contains(touch.location(in: self))
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        
        guard let touch = touch else {
            return
        }
        
        var newSelectedIndex: Int?
        
        segmentedItemControls.forEach { (segmentedItemControl) in
            let isTouchOnItemCards = segmentedItemControl.bounds.contains(touch.location(in: segmentedItemControl))
            if isTouchOnItemCards && segmentedItemControl.isEnabled {
                newSelectedIndex = segmentedItemControl.tag
            }
        }
        
        selectedIndex = newSelectedIndex ?? selectedIndex
        
    }
    
    override func cancelTracking(with event: UIEvent?) {
        setSelectedIndexItemCardControlSelected()
    }
    
    private func setupItems() {
        // Setup Items
        guard let items = items else { return }
        items.enumerated().forEach { (index, item) in
            let itemCardControl = SegmentedItemControl(title: item.title,
                                                  subtitle: item.subtitle)
            itemCardControl.tag = index
            itemCardControl.isEnabled = item.isEnabled
            segmentedItemControls.append(itemCardControl)
            stackView.addArrangedSubview(itemCardControl)
        }
        if let selectedIndex = items.firstIndex(where: {
            $0.isEnabled
        }) {
            self.selectedIndex = selectedIndex
        }
    }
    
    private func setSelectedIndexItemCardControlSelected() {
        segmentedItemControls.forEach { (segmentedItemControl) in
            segmentedItemControl.isSelected = selectedIndex == segmentedItemControl.tag && segmentedItemControl.isEnabled
            segmentedItemControl.isHighlighted = false
        }
    }
    
    func setupTheme() {
        layer.setLayer(layerStyle.segmentedControl.normal())
        stackView.arrangedSubviews.forEach { (segmentedItemControl) in
            guard let segmentedItemControl = segmentedItemControl as? SegmentedItemControl else { return }
            segmentedItemControl.setupTheme()
        }
    }
}
