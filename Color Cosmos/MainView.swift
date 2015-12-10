//
//  MainView.swift
//  Color Cosmos
//
//  Created by AbdelGhafour on 11/18/15.
//  Copyright © 2015 Abdou23. All rights reserved.
//

import SpriteKit


class MainView: SKView {
    
    override var paused: Bool {
        get {
            return super.paused
        }
        set {
            
        }
    }
    
    func pause() {
        super.paused = true
    }
    
    func resume() {
        super.paused = false
    }
    
    func togglePause() {
        super.paused = !super.paused
    }
    
}
