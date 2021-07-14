//
//  MessageInputBar.swift
//  MessageInputBar
//
//  Created by Lumia_Saki on 2021/7/14.
//  Copyright © 2021年 tianren.zhu. All rights reserved.
//

import Foundation
import UIKit

/// Modularized text input bar.
public final class MessageInputBar: UIView {
    
    // MARK: - UI Elements
    
    private lazy var container: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 12
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(top: 7, left: 12, bottom: 7, right: 12)
        return view
    }()
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        view.returnKeyType = .default
        view.showsVerticalScrollIndicator = false
        view.font = .systemFont(ofSize: 16)
        view.delegate = self
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var functionArea: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .bottom
        view.spacing = 8
        view.isHidden = true
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    private lazy var controlArea: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .bottom
        view.spacing = 8
        view.isHidden = true
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    // MARK: - Public Properties
        
    /// Current content of input bar.
    public var text: String { textView.text }
    
    /// Configure max height for input bar, when the height hit the value, input bar will enable scrolling.
    public var textViewMaxHeight: CGFloat = 100 {
        willSet {
            DispatchQueue.main.async {
                self.textViewMaxHeightConstraint = self.textView.heightAnchor.constraint(equalToConstant: newValue)
                self.updateConstraintsIfNeeded()
            }
        }
    }
    
    /// Set font for input bar.
    public var textFont: UIFont? {
        set { textView.font = newValue }
        get { textView.font }
    }
    
    // MARK: - Private Properties
    
    private lazy var functionElements: [MessageInputElement] = Array()
    private lazy var controlElements: [MessageInputElement] = Array()
    
    private lazy var elementIdentifierPair: [UUID : (element: MessageInputElement, button: UIButton, location: MessageInputElementLocation)] = Dictionary()
        
    private var textViewMaxHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpUIElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public

extension MessageInputBar {
    
    /// Add element to input bar.
    /// - Parameters:
    ///   - element: MessageInputElement.
    ///   - location: MessageInputElementLocation.
    public func add(element: MessageInputElement, at location: MessageInputElementLocation) {
        let targetContainer = self.targetContainer(for: location)
        
        DispatchQueue.main.async {
            let button = self.generateView(with: element)
            self.elementIdentifierPair[element.id] = (element, button, location)
            
            targetContainer.addArrangedSubview(button)
            targetContainer.isHidden = targetContainer.arrangedSubviews.isEmpty
            
            switch location {
            case .controlLocation:
                self.controlElements.append(element)
            case .functionLocation:
                self.functionElements.append(element)
            }
        }
    }
    
    /// Remove element from input bar.
    /// - Parameter element: MessageInputElement.
    public func remove(element: MessageInputElement) {
        DispatchQueue.main.async {
            guard let tuple = self.elementIdentifierPair[element.id] else {
                return
            }
                        
            let targetContainer = self.targetContainer(for: tuple.location)
            targetContainer.removeArrangedSubview(tuple.button)
            targetContainer.isHidden = targetContainer.arrangedSubviews.isEmpty
            
            self.elementIdentifierPair.removeValue(forKey: element.id)
            
            switch tuple.location {
            case .functionLocation:
                self.functionElements.removeAll { $0.id == element.id }
            case .controlLocation:
                self.controlElements.removeAll { $0.id == element.id }
            }
        }
    }
    
    /// Reset content of input bar to empty.
    public func resetText() {
        DispatchQueue.main.async {
            self.textView.text = ""
            self.reconcileInputBarState()
        }
    }
}

// MARK: - Private

extension MessageInputBar {
    
    private func setUpUIElements() {
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .systemGray3
        
        addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.topAnchor.constraint(equalTo: topAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
        
        addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.topAnchor.constraint(equalTo: lineView.bottomAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
                
        let leadingPart = UIStackView()
        leadingPart.translatesAutoresizingMaskIntoConstraints = false
        leadingPart.axis = .horizontal
        leadingPart.spacing = 12
        leadingPart.backgroundColor = .systemGray6
        
        leadingPart.addArrangedSubview(functionArea)
        leadingPart.addArrangedSubview(textView)
        
        textViewMaxHeightConstraint = textView.heightAnchor.constraint(equalToConstant: textViewMaxHeight)
        container.addArrangedSubview(leadingPart)
        container.addArrangedSubview(controlArea)
    }
    
    private func targetContainer(for location: MessageInputElementLocation) -> UIStackView {
        switch location {
        case .controlLocation:
            return controlArea
        case .functionLocation:
            return functionArea
        }
    }
    
    private func generateView(with element: MessageInputElement) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = element.enable?(element, self) ?? true
        button.addTarget(self, action: #selector(elementButtonSelected(_:)), for: .touchUpInside)
        attachIdentifier(to: button, element: element)
        
        // configure icon for button
        do {
            switch element.icon {
            case .icon(let iconImage):
                button.setImage(iconImage, for: .normal)
            case .sfIconName(let sfIconName):
                let config = UIImage.SymbolConfiguration(
                    pointSize: textView.intrinsicContentSize.height * (2 / 3), weight: .thin, scale: .default)
                let image = UIImage(systemName: sfIconName, withConfiguration: config)
                button.setImage(image, for: .normal)
            }
        }
        
        let size: CGSize = .init(width: textView.intrinsicContentSize.height, height: textView.intrinsicContentSize.height)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: size.width),
            button.heightAnchor.constraint(equalToConstant: size.height)])
        
        return button
    }
    
    private func enableTextViewScroll(enabled: Bool) {
        textView.isScrollEnabled = enabled
        textViewMaxHeightConstraint?.isActive = enabled
        textView.setNeedsUpdateConstraints()
    }
    
    private func reconcileInputBarState() {
        enableTextViewScroll(enabled: textView.contentSize.height >= textViewMaxHeight)
        
        for element in controlElements {
            if let enabled = element.enable?(element, self), let tuple = elementIdentifierPair[element.id] {
                tuple.button.isEnabled = enabled
            }
        }
    }
    
    private struct AssociatedObjectKey {
        
        static var identifier: Void?
    }
    
    private func attachIdentifier(to button: UIButton, element: MessageInputElement) {
        objc_setAssociatedObject(button, &AssociatedObjectKey.identifier, element.id, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func extractIdentifier(from button: UIButton) -> UUID? {
        return objc_getAssociatedObject(button, &AssociatedObjectKey.identifier) as? UUID
    }
    
    @objc
    private func elementButtonSelected(_ sender: UIButton) {
        guard let identifier = extractIdentifier(from: sender), let tuple = elementIdentifierPair[identifier] else {
            return
        }
        
        tuple.element.action?(tuple.element, self)
    }
}

// MARK: - UITextViewDelegate

extension MessageInputBar: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        reconcileInputBarState()
    }
}
