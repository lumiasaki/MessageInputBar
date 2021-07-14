//
//  MessageInputElement.swift
//  MessageInputBar
//
//  Created by Lumia_Saki on 2021/7/14.
//  Copyright © 2021年 tianren.zhu. All rights reserved.
//

import Foundation
import UIKit

/// Locations for message input element can be added.
public enum MessageInputElementLocation {
    
    /// Function area, located in left side of text input view.
    case functionLocation
    
    /// Control area, located in right side of text input view.
    case controlLocation
}

/// A type to enhance the input bar.
public final class MessageInputElement: Identifiable {
    
    public enum Icon {
        
        case icon(UIImage)
        case sfIconName(String)
    }
    
    /// Identifier of element.
    public let id: UUID
    
    /// Icon of the element.
    public let icon: Icon
    
    /// Invoked when the element be tapped.
    public var action: ((MessageInputElement, MessageInputBar) -> Void)?
    
    /// Invoked when asking the element enabled status.
    public var enable: ((MessageInputElement, MessageInputBar) -> Bool)?
    
    public init(icon: Icon) {
        self.id = UUID()
        self.icon = icon
    }
}
