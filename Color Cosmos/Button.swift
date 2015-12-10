//
//  Button.swift
//  Color Cosmos
//
//  Created by AbdelGhafour on 11/18/15.
//  Copyright © 2015 Abdou23. All rights reserved.
//

import SpriteKit

class Button: SKNode {
    
    
    var defaultButton: SKSpriteNode
    var action: () -> Void
    
    init(defaultImage: String, buttonAction: () -> Void) {
        
        defaultButton = SKSpriteNode(imageNamed: defaultImage)
        action = buttonAction
        
        super.init()
        
        userInteractionEnabled = true
        
        addChild(defaultButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            defaultButton.alpha = 0.5
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            if defaultButton.containsPoint(location) {
                action()
            }
            defaultButton.alpha = 1

        }
    }
    
    
    
    
    
    
}

