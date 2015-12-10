//
//  GameViewController.swift
//  Color Cosmos
//
//  Created by AbdelGhafour on 11/18/15.
//  Copyright (c) 2015 Abdou23. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Gamecenter
        //authenticateLocalPlayer()
        
        let scene  = GameScene()
        // Configure the view.
        let skView =  self.view as! MainView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsPhysics = false
        
        NSNotificationCenter.defaultCenter().addObserver(skView, selector:Selector("pause"), name: "PauseViewNotification", object: nil)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        scene.size = skView.bounds.size
        
        skView.presentScene(scene)
        
        canDisplayBannerAds = true
        

        
    }
    
    // Gamecenter
    
    //initiate gamecenter
    func authenticateLocalPlayer(){
        print("Starting..")
        let localPlayer = GKLocalPlayer.localPlayer()
         print("Starting..1")
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
             print("Starting..2")
            if (error != nil)
            {
                //add some stuff to report the error
                print("Gamecenter Error")
            }
            else if (viewController != nil){
                print("Not signed in. Authenticating now")
                var vc = self.view?.window?.rootViewController
                vc?.presentViewController(viewController!, animated: true, completion: nil)
            }
                
            else {
                 print("Starting..3")
                print((GKLocalPlayer.localPlayer().authenticated))
                
            }
            
        }
    }
    


    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
