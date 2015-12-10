//
//  GameScene.swift
//  Color Cosmos
//
//  Created by AbdelGhafour on 11/18/15.
//  Copyright (c) 2015 Abdou23. All rights reserved.
//

import SpriteKit
import iAd
import GameKit

//MARK:- Physics
struct PhysicsCategory {
    
    static let HeroCategory: UInt32 =          0x1 << 0
    static let HeroRightCategory: UInt32 =     0x1 << 1
    static let BlockCategory: UInt32 =         0x1 << 2
}

var score = 0
var highScore = 0


class GameScene: SKScene, SKPhysicsContactDelegate, ADBannerViewDelegate, GKGameCenterControllerDelegate {
    
    // iAds
    //var iAd = ADInterstitialAd()
    var adView = UIView()
    var iAd = ADBannerView()
    
    //MARK:- Variables
    let backLax = SKNode()  // Background Parallax
    let foreLax = SKNode()         // Foreground Parallax
    // Layers
    let blockLayer = SKNode()
    let heroLayer = SKNode()
    let bgLayer = SKNode()
    let pauseLayer = SKNode()
    
    // Nodes
    var parallaxAssets = SKSpriteNode()
    var bg = SKSpriteNode()
    var light = SKSpriteNode()
    var block = SKSpriteNode()
    var blockLeft = SKSpriteNode()
    var blockRight = SKSpriteNode()
    var hero = SKSpriteNode()
    var heroRight = SKSpriteNode()
    var blockParticle = SKEmitterNode()
    var heroparticle = SKEmitterNode()
    var pauseScreen = SKSpriteNode()
    var transitionScreen = SKSpriteNode()
    
    // Labels
    var scoreLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    var highScoreLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    var startLabel = SKLabelNode(fontNamed: "STHeitiTC-Medium")
    var instructionsLabel = UILabel()
    var hsFrame = SKSpriteNode() // highscore label frame
    
    // Values
    var previous = UInt32()
    var previous2 = UInt32()
    var colorNumber = 0
    var colorNumberRight = 0
    var score = 0
    var highScore = 0
    var qWidth: CGFloat!
    var maxX: CGFloat!
    var maxY: CGFloat!
    
    // Colors
    let yellowColor = UIColor(red: 255 / 255, green: 218 / 255, blue: 69 / 255, alpha: 1)
    let cyanColor = UIColor(red: 76 / 255, green: 191 / 255, blue: 195 / 255, alpha: 1)
    let redColor = UIColor(red: 255 / 255, green: 98 / 255, blue: 82 / 255, alpha: 1)
    let blueColor = UIColor(red: 82 / 255, green: 127 / 255, blue: 255 / 255, alpha: 1)
    let pinkColor = UIColor(red: 250 / 255, green: 82 / 255, blue: 173 / 255, alpha: 1)
    
    // Timers
    
    var lastUpdate: NSTimeInterval = 0
    var deltaTime: CGFloat = 0.16
    
    // Actions
    
    var spawnBlockAction = SKAction()
    
    // Bools
    var isStarted = false
    var isFirstTime = true
    var isPhaseOne = true
    var isAd = false
    var isPause = false
    var isSmallScreen = false
    
    // Arrays
    var colors = [UIColor]()
    var names = [String]()
    var parallax = [[SKSpriteNode](), [SKSpriteNode]()]
    var parallaxSpeed: [CGFloat] = [60, 40]
    var parallaxAtlas = [SKTexture]()
    var foreSprites = [SKSpriteNode]() // used in randomizing parallax
    
    // Buttons
    
    var pauseButton: Button!
    var playButton: Button!
    var likeButton: Button!
    var soundButton: Button!
    var gameCenterButton: Button!
    
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.contactDelegate = self
        iAd.delegate = self
        
        
        
        anchorPoint = CGPointZero
        
        if size.width < 375{
            
            isSmallScreen = true
        }
        print(isSmallScreen)
        
        addChild(backLax)
        addChild(foreLax)
        //addChild(blockLayer)
        addChild(bgLayer)
        addChild(heroLayer)
        addChild(pauseLayer)
        
        
        bgLayer.zPosition = -10
        backLax.zPosition = -5
        foreLax.zPosition = -4
        pauseLayer.zPosition = 10
        heroLayer.zPosition = 10
        
        qWidth = size.width / 4
        maxX = frame.width
        maxY = frame.height
        
        if let storedHighScore: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("highScore") {
            
            highScore = storedHighScore as! Int
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("pauseGame"), name: "ShowPauseScreenNotification", object: nil)
        
        
        colors = [yellowColor, blueColor, pinkColor, redColor, blueColor]
        names = ["yellow","violet", "pink", "red", "blue"]
                
        //iAd.center.y = UIScreen.mainScreen().bounds.height - iAd.frame.size.height
        view.addSubview(iAd)
        
        iAd.hidden = true
        iAd.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
        authenticateLocalPlayer()
        
        createBackground("BG")
        createHomescreen()
        createLabels()
        createPauseButton()
        createTransitionScreen()
        
        
    }
    
    
    
    //MARK:- iAds
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        if (!isStarted){
         
            iAd.hidden = false
        }
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        
        print("Ad Fail")
        iAd.hidden = true
    }
    
    /*
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
    
    adView.removeFromSuperview()
    isAd = false
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
    
    if iAd.loaded && !isStarted {
    
    isAd = true
    adView.frame = (self.view?.bounds)!
    self.view!.addSubview(adView)
    
    iAd.presentInView(adView)
    UIViewController.prepareInterstitialAds()
    print("Ad Loaded")
    }
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
    
    adView.removeFromSuperview()
    isAd = false
    print("Ad ended")
    
    }
    
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
    
    return true
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
    
    adView.removeFromSuperview()
    isAd = false
    print("Ad Error  + \(error)")
    }
    */
    
    //MARK:- Social
    
    func faceBook() {
        
        
    }
    
    func gameCenter() {
        
        showLeader()
    }
    
    
    //MARK:- Pause
    
    
    func pauseGame() {
        if (!isFirstTime) {
            pauseScreen.hidden = false
            pauseButton.hidden = false
            // Un-pause the view so the screen and button appear
            if let customView = self.view as? MainView {
                customView.resume()
            }
            // Re-pause the view after returning to the main loop
            let pauseAction = SKAction.runBlock({
                [weak self] in
                if let customView = self?.view as? MainView {
                    customView.pause()
                    self!.isPause = true
                }
                })
            if (!isStarted) {
                
                pauseScreen.hidden = true
                pauseButton.hidden = true
            } else {
                
                runAction(pauseAction)
            }
        }
        isFirstTime = false
        
    }
    
    
    func pauseButtonToggle() {
        
        print("Clicked")
        if let customView = self.view as? MainView {
            customView.togglePause()
        }
        if isPause {
            
            pauseScreen.hidden = true
            pauseButton.hidden = true
            isPause = false
            
        } else {
            
            pauseScreen.hidden = false
            pauseButton.hidden = false
            isPause = true
        }
        
    }
    
    //MARK:- Sound
    
    func soundToggle() {
        
    }
    
    //MARK:- Setup
    
    func randomRange(min: CGFloat, max: CGFloat) -> CGFloat {
        
        let min = UInt32(min)
        let max = UInt32(max)
        
        let random = arc4random_uniform(max - min) + min
        
        return CGFloat(random)
    }
    
    func randomNumber(max: UInt32) -> UInt32 {
        
        var random = arc4random_uniform(max)
        
        while previous == random {
            
            random = arc4random_uniform(max)
        }
        
        previous = random // Previous should be on the left
        
        return random
    }
    
    func randomNumber2(max: UInt32) -> UInt32 {
        
        var random = arc4random_uniform(max)
        
        while previous2 == random {
            
            random = arc4random_uniform(max)
        }
        
        previous2 = random // Previous should be on the left
        
        return random
    }
    
    
    func newGame() {
        
        score = 0
        /*
        spawnTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "createBlock", userInfo: nil, repeats: true)
        spawnTwoBlocks = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "createTwoBlocks", userInfo: nil, repeats: true)
        */
        addChild(blockLayer)
        //addChild(heroLayer)
        spawnBlock()
        spawnTwoBlocks()
        
        scoreLabel.text = "\(score)"
        createHero()
        isStarted = true
        randomBGAndParallax()
        
        highScoreLabel.hidden = true
        playButton.hidden = true
        likeButton.hidden = true
        gameCenterButton.hidden = true
        soundButton.hidden = true
        
        iAd.hidden = true
        
        if scoreLabel.hidden == true {
            
            scoreLabel.hidden = false
        }
        
        if isFirstTime {
            
            isFirstTime = false
            
        } else {
            
            scoreLabel.runAction(SKAction.sequence([SKAction.moveToY(size.height - 40, duration: 0.5), SKAction.scaleTo(1, duration: 1)]))
            
        }
        
    }
    
    
    func gameOver() {
        
        if score > highScore {
            
            setHighScore()
            highScoreLabel.text = "Highscore: \(highScore)"
            saveHighscore(highScore)
            
        }
        //isStarted = false
        //interstitialAdDidLoad(iAd)
        
        blockLayer.removeAllChildren()
        backLax.removeAllChildren()
        foreLax.removeAllChildren()
        bgLayer.removeAllChildren()
        bgLayer.removeAllChildren()
        heroLayer.removeAllChildren()
        hero.removeFromParent()
        heroRight.removeFromParent()
        light.removeFromParent()
        foreSprites.removeAll()
        parallax[0].removeAll()
        parallax[1].removeAll()
        removeAllActions()
        
        score = 0
        
        isPhaseOne = true
        colorNumber = 0
        colorNumberRight = 0
        
        createBackground("BG")
        
        highScoreLabel.hidden = false
        playButton.hidden = false
        likeButton.hidden = false
        gameCenterButton.hidden = false
        soundButton.hidden = false
        
        iAd.hidden = false
        scoreLabel.runAction(SKAction.sequence([SKAction.moveToY(size.height / 2, duration: 0.5), SKAction.scaleTo(1.3, duration: 1)]))
        
    }
    
    
    //MARK:- Creations
    
    func randomBGAndParallax() {
        
        let random = arc4random_uniform(2)
        
        if random == 0 {
            
            createParallax(8, backMax: 15, foreS: "cloud_big", backS: "cloud_small")
            createBackground("Day_BG")
            createLight("Sun")
            
        } else {
            
            createParallax(32, backMax: 28, foreS: "star_mid", backS: "star_small")
            createBackground("Night_BG")
            createLight("Moon")
        }
    }
    
    func createParallax(foreMax: Int, backMax: Int, foreS: String, backS: String) {
        
        for index in 0...foreMax {
            
            let sprite = SKSpriteNode(imageNamed: foreS)
            parallax[0].append(sprite)
            foreLax.addChild(sprite)
        }
        
        for currentSprite in parallax[0]{
            
            var intersects = true
            
            while (intersects){
                
                let xPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxX
                let yPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxY
                
                currentSprite.position = CGPoint(x: xPos, y: yPos )
                
                intersects = false
                
                for sprite in foreSprites{
                    if currentSprite.intersectsNode(sprite){
                        
                        intersects = true
                        break
                    }
                }
            }
            
            foreSprites.append(currentSprite)
        }
        
        for index in 0...backMax {  //22
            
            let sprite = SKSpriteNode(imageNamed: backS)
            let xPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxX
            let yPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxY
            sprite.position = CGPoint(x: xPos, y: yPos)
            sprite.size = CGSize(width: sprite.size.width / 2, height: sprite.size.height / 2)
            sprite.alpha = 0.5
            
            parallax[1].append(sprite)
            backLax.addChild(sprite)
        }
    }
    
    func createBackground(name: String) {
        
        if bgLayer.children.count != 0 {
            
            bgLayer.removeAllChildren()
        }
        
        bg = SKSpriteNode(imageNamed: name)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bgLayer.addChild(bg)
        
    }
    
    func createLight(name: String) {
        
        light = SKSpriteNode(imageNamed: name)
        light.position = CGPoint(x: light.size.width, y: size.height - light.size.height)
        light.zPosition = -1
        addChild(light)
        
    }
    
    func createPauseScreen() {
        
        pauseScreen = SKSpriteNode(color: UIColor.blackColor(), size: size)
        pauseScreen.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pauseScreen.alpha = 0.5
        pauseScreen.zPosition = 10
        pauseScreen.hidden = true
        pauseLayer.addChild(pauseScreen)
    }
    
    func createTransitionScreen() {
        
        transitionScreen = SKSpriteNode(color: UIColor.whiteColor(), size: size)
        transitionScreen.position = CGPoint(x: size.width / 2, y: size.height / 2)
        transitionScreen.alpha = 0
        transitionScreen.zPosition = 10
        addChild(transitionScreen)
    }
    
    func createHomescreen() {
        
        let testImage = SKSpriteNode(imageNamed: "Like")
        
        playButton = Button(defaultImage: "Play", buttonAction: newGame)
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        addChild(playButton)
        
        likeButton = Button(defaultImage: "Like", buttonAction: faceBook)
        likeButton.position = CGPointMake(size.width / 2 - (testImage.size.width * 1.2), size.height / 2 - 200)
        addChild(likeButton)
        
        gameCenterButton = Button(defaultImage: "Gamecenter", buttonAction: gameCenter)
        gameCenterButton.position = CGPointMake(size.width / 2 , size.height / 2 - 200)
        addChild(gameCenterButton)
        
        soundButton = Button(defaultImage: "Sound", buttonAction: soundToggle)
        soundButton.position = CGPointMake(size.width / 2 + (testImage.size.width * 1.2), size.height / 2 - 200)
        addChild(soundButton)
        
        
    }
    
    func createLabels() {
        
        // ScoreLabel
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.alpha = 0.55
        scoreLabel.hidden = true
        
        addChild(scoreLabel)
        
        /*
        // StartGame Label
        startLabel.text = "Play"
        startLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        startLabel.fontSize = 50
        startLabel.fontColor = UIColor.grayColor()
        
        addChild(startLabel)
        
        startLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeInWithDuration(1.5), SKAction.fadeOutWithDuration(1)])))
        
        // Instructions Label <- UILabel
        instructionsLabel = UILabel(frame: CGRectMake(30 , 500 , size.width, 40))
        instructionsLabel.text = "Tap to match ball color with block color"
        instructionsLabel.font = UIFont(name: "STHeitiTC-Medium", size: 20)
        instructionsLabel.numberOfLines = 0
        instructionsLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        instructionsLabel.sizeToFit()
        instructionsLabel.textAlignment = NSTextAlignment.Center
        instructionsLabel.textColor = UIColor.yellowColor()
        
        view?.addSubview(instructionsLabel) // <- View not self
        
*/
        hsFrame = SKSpriteNode(color: SKColor.grayColor(), size: CGSizeMake(300, 50))
        hsFrame.position = CGPoint(x: size.width / 2, y: size.height / 2 - 70)
        //addChild(hsFrame)
        
        highScoreLabel.text = "Highscore: \(highScore)"
        highScoreLabel.position = CGPoint(x: size.width / 2, y: playButton.position.y - 80)
        highScoreLabel.fontSize = 30
        highScoreLabel.fontColor = UIColor.whiteColor()
        
       addChild(highScoreLabel)

        
    }
    
    
    
    func createBlock() {
        
        let randomColor = Int(randomNumber(5))
        
        block = SKSpriteNode(imageNamed: "\(names[randomColor])" + "_bar")
        block.position = CGPoint(x: size.width / 2, y: size.height )
        block.name = "\(names[randomColor])"
        
        if isSmallScreen{
            block.size = CGSize(width: block.size.width * 0.7, height: block.size.height * 0.7)
        }
        
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.categoryBitMask = PhysicsCategory.BlockCategory
        block.physicsBody?.contactTestBitMask = PhysicsCategory.HeroCategory
        
        
        
        block.color = colors[randomColor]
        block.runAction(SKAction.moveTo(CGPoint(x: block.position.x, y: 0 - block.size.height), duration: 3))
        blockLayer.addChild(block)
    }
    
    func createTwoBlocks() {
        
        if !isPhaseOne {
            
            
            let randomColor = Int(randomNumber2(5))
            let randomColorRight = Int(randomNumber(5))
            
            blockLeft = SKSpriteNode(imageNamed: "\(names[randomColor])" + "_bar")
            blockLeft.size = CGSize(width: block.size.width / 1.5, height: block.size.height)
            blockLeft.position = CGPoint(x: 25 + blockLeft.size.width / 2, y: size.height )
            blockLeft.name = "\(names[randomColor])"
            
            if isSmallScreen{
                blockLeft.size = CGSize(width: block.size.width * 0.7, height: block.size.height * 0.7)
            }
            
            blockLeft.physicsBody = SKPhysicsBody(rectangleOfSize: blockLeft.size)
            blockLeft.physicsBody?.affectedByGravity = false
            blockLeft.physicsBody?.categoryBitMask = PhysicsCategory.BlockCategory
            blockLeft.physicsBody?.contactTestBitMask = PhysicsCategory.HeroCategory
            
            blockLeft.color = colors[randomColor]
            
            blockLeft.runAction(SKAction.moveTo(CGPoint(x: blockLeft.position.x, y: 0 - blockLeft.size.height), duration: 3))
            
            blockLayer.addChild(blockLeft)
            
            // Right
            blockRight = SKSpriteNode(imageNamed: "\(names[randomColorRight])" + "_bar")
            blockRight.size = CGSize(width: block.size.width / 1.5, height: blockRight.size.height)
            blockRight.position = CGPoint(x: size.width / 2 + 30 + blockRight.size.width / 2, y: size.height )
            
            blockRight.name = "\(names[randomColorRight])"
            
            if isSmallScreen{
                blockRight.size = CGSize(width: block.size.width * 0.7, height: block.size.height * 0.7)
            }
            
            blockRight.physicsBody = SKPhysicsBody(rectangleOfSize: blockRight.size)
            blockRight.physicsBody?.affectedByGravity = false
            blockRight.physicsBody?.categoryBitMask = PhysicsCategory.BlockCategory
            blockRight.physicsBody?.contactTestBitMask = PhysicsCategory.HeroCategory
            
            blockRight.color = colors[randomColorRight]
            
            blockRight.runAction(SKAction.moveTo(CGPoint(x: blockRight.position.x, y: 0 - blockRight.size.height), duration: 4.5))
            
            blockLayer.addChild(blockRight)
            
        }
        
    }
    
    
    func createHero() {
        
        hero = SKSpriteNode(imageNamed: "blue_ball")
        hero.position = CGPoint(x: size.width / 2, y: size.height / 2 - (hero.size.height * 2.5))
        hero.size = CGSizeMake(hero.size.width / 2, hero.size.height / 2)
        hero.name =  "blue"
        hero.color = colors.last!
        
        if isSmallScreen{
            hero.size = CGSize(width: hero.size.width * 0.7, height: hero.size.height * 0.7)
        }
        
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.width / 2)
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.dynamic = false
        hero.physicsBody?.categoryBitMask = PhysicsCategory.HeroCategory
        hero.physicsBody?.contactTestBitMask = PhysicsCategory.BlockCategory
        
        addChild(hero)
        
        hero.runAction(SKAction.scaleTo(2, duration: 0.5))
        print(hero.size)
    }
    
    
    func createHeroRight() {
        
        heroRight = SKSpriteNode(imageNamed: "blue_ball")
        heroRight.position = CGPoint(x: (size.width - qWidth), y: size.height / 2 - (heroRight.size.height * 2.5))
        heroRight.size = CGSizeMake(heroRight.size.width / 2, heroRight.size.height / 2)
        heroRight.name = "blue"
        heroRight.color = colors.last!
        
        if isSmallScreen{
            heroRight.size = CGSize(width: heroRight.size.width * 0.7, height: heroRight.size.height * 0.7)
        }
        
        heroRight.physicsBody = SKPhysicsBody(circleOfRadius: heroRight.size.width / 2)
        heroRight.physicsBody?.affectedByGravity = false
        heroRight.physicsBody?.dynamic = false
        heroRight.physicsBody?.categoryBitMask = PhysicsCategory.HeroRightCategory
        heroRight.physicsBody?.contactTestBitMask = PhysicsCategory.BlockCategory
        
        addChild(heroRight)
        
        heroRight.runAction(SKAction.scaleTo(2, duration: 0.5))
    }
    
    
    //MARK:- Effects
    
    func ballPressed(ball: SKSpriteNode) {
        
        let scaleDown = SKAction.scaleTo(1.9, duration: 0.05)
        let scaleUp = SKAction.scaleTo(2, duration: 0.05)
        
        ball.runAction(SKAction.sequence([scaleDown, scaleUp]))
    }
    
    func ballEnded(ball: SKSpriteNode) {
        
        blockLayer.removeAllChildren()
        blockLayer.removeAllActions()
        blockLayer.removeFromParent()
        
        isStarted = false
        
        let scale = SKAction.scaleTo(5, duration: 3)
        let twerkRight = SKAction.moveByX(10, y: 0, duration: 0.05)
        let twerkRightBack = SKAction.reversedAction(twerkRight)
        let twerkLeft = SKAction.moveByX(-10, y: 0, duration: 0.05)
        let twerkLeftBack = SKAction.reversedAction(twerkLeft)
        let twerking = SKAction.repeatAction(SKAction.sequence([twerkRight,twerkRightBack(), twerkLeft, twerkLeftBack()]), count: 7)
        let move = SKAction.moveTo(CGPoint(x: size.width / 2, y: size.height / 2 + 50), duration: 3)
        let transitionOut = SKAction.runBlock({
            self.transitionScreen.runAction(SKAction.fadeAlphaTo(1, duration: 2.5))
            print("Transition Out")
        })
        let transitionIn = SKAction.runBlock({
            self.transitionScreen.runAction(SKAction.fadeAlphaTo(0, duration: 0.1))
            print("Transition In")
        })
        
        let showParticles = SKAction.runBlock({
            
            self.ballDestroyed(ball)
            ball.hidden = true
            //self.hero.removeFromParent()
            //self.heroRight.removeFromParent()
            print("Show Particle")
        })
        
        let gameOver = SKAction.runBlock({
            self.gameOver()
        })
        
        let wait = SKAction.waitForDuration(3)
        let group = SKAction.group([scale,move])
        
        ball.runAction(SKAction.sequence([group,twerking, showParticles, transitionOut, wait, transitionIn, gameOver]))
    }
    
    func ballDestroyed(ball: SKSpriteNode) {
        
        let heroParticlePath = NSBundle.mainBundle().pathForResource("HeroDestroyed", ofType: "sks")
        heroparticle = NSKeyedUnarchiver.unarchiveObjectWithFile(heroParticlePath!) as! SKEmitterNode
        heroparticle.zPosition = 30
        heroparticle.position = CGPoint(x: ball.position.x, y: ball.position.y)
        heroparticle.particleColor = ball.color
        heroparticle.particleColorBlendFactor = 1
        addChild(heroparticle)
    }
    
    func blockDestroyed(block: SKSpriteNode) {
        
        let particlePath = NSBundle.mainBundle().pathForResource("DestroyedRight", ofType: "sks")
        blockParticle = NSKeyedUnarchiver.unarchiveObjectWithFile(particlePath!) as! SKEmitterNode
        blockParticle.zPosition = 10
        blockParticle.position = CGPoint(x: block.position.x, y: block.position.y + 4)
        blockParticle.particleColor = block.color
        blockParticle.particleColorBlendFactor = 1
        
        blockLayer.addChild(blockParticle)
        
        let particlePathLeft = NSBundle.mainBundle().pathForResource("DestroyedLeft", ofType: "sks")
        let blockParticleLeft = NSKeyedUnarchiver.unarchiveObjectWithFile(particlePathLeft!) as! SKEmitterNode
        blockParticleLeft.zPosition = 10
        blockParticleLeft.position = CGPoint(x: block.position.x, y: block.position.y + 4)
        blockParticleLeft.particleColor = block.color
        blockParticleLeft.particleColorBlendFactor = 1
        
        blockLayer.addChild(blockParticleLeft)
        
    }
    
    
    
    func spawnBlock() {
        
        let wait = SKAction.waitForDuration(2.5)
        
        let spawn = SKAction.runBlock({
            self.createBlock()
        })
        
        
        spawnBlockAction = SKAction.sequence([wait, spawn])
        runAction(SKAction.repeatActionForever(spawnBlockAction), withKey: "oneBlock")
        
    }
    
    func spawnTwoBlocks() {
        
        let wait = SKAction.waitForDuration(3.5)
        
        let spawn = SKAction.runBlock({
            self.createTwoBlocks()
        })
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([wait, spawn])))
    }
    
    func changeHeroColor(heroNum: Int, hero: SKSpriteNode) {
        
        if heroNum == 1 {
            
            if colorNumber >= colors.count {
                
                colorNumber = 0
            }
            
            
            hero.texture = SKTexture(imageNamed: "\(names[colorNumber])" + "_ball")
            hero.name = names[colorNumber]
            hero.color = colors[colorNumber]
            colorNumber++
            
        } else {
            
            if colorNumberRight >= colors.count {
                
                colorNumberRight = 0
            }
            
            hero.texture = SKTexture(imageNamed: "\(names[colorNumberRight])" + "_ball")
            hero.name = names[colorNumberRight]
            hero.color = colors[colorNumberRight]
            colorNumberRight++
        }
        
    }
    
    func moveParallaxLayer(parallax: [SKSpriteNode], speed: CGFloat) {
        
        var sprite = SKSpriteNode()
        var newY: CGFloat = 0
        
        for index in 0...parallax.count-1 {
            
            sprite = parallax[index]
            newY = sprite.position.y - 1 * speed * deltaTime
            
            sprite.position.y = boundCheck(newY)
        }
        
    }
    
    func boundCheck(var yPos: CGFloat) -> CGFloat {
        
        if yPos < 0 {
            
            yPos += maxY + 100
        }
        
        return yPos
    }
    
    func checkInterception(sprite1: SKSpriteNode, sprite2: [SKSpriteNode]) {
        
        let xPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxX
        let yPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * maxY
        sprite1.position = CGPoint(x: xPos, y: yPos )
        
        for index in 0...sprite2.count-1 {
            
            if sprite1.intersectsNode(sprite2[index]) {
                
                
                let yPos = sprite1.position.y + sprite1.size.height
                sprite1.position = CGPoint(x: xPos, y: yPos )
                
            }
            
        }
        
    }
    
    func setHighScore() {
        
        highScore = score
        NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey: "highScore")
    }
    
    //MARK:- Buttons
    
    func createPauseButton() {
        
        pauseButton = Button(defaultImage: "red_ball", buttonAction: pauseButtonToggle)
        pauseButton.position = CGPoint(x: size.width / 2, y: self.size.height - 200)
        pauseButton.hidden = true
        pauseLayer.addChild(pauseButton)
    }
    
    func createButton( image: UIImage, activeImage: UIImage, action: () -> Void) {
        
        
    }
    
    //MARK:- Touch
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            
            if isPause {
                
                if pauseButton.containsPoint(location) {
                    print("Clicked2")
                    pauseButtonToggle()
                }
            } else {
                
                if isStarted {
                    
                    if !isPhaseOne {
                        
                        if location.x < size.width / 2 {
                            
                            changeHeroColor(1, hero: hero)
                            ballPressed(hero)
                            
                        } else {
                            
                            changeHeroColor(2, hero: heroRight)
                            ballPressed(heroRight)
                        }
                        
                    } else  {
                        
                        changeHeroColor(1, hero: hero)
                        ballPressed(hero)
                    }
                    
                } else if !isAd && startLabel.containsPoint(location) {
                    
                        newGame()
                    
                }
                
            }
        }
    }
    
    //MARK:- Contact
    func didBeginContact(contact: SKPhysicsContact) {
        
        // Setup
        let firstBody: SKPhysicsBody!
        let secondBody: SKPhysicsBody!
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        } else {
            
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Collisions
        
        if firstBody.categoryBitMask == PhysicsCategory.HeroCategory && secondBody.categoryBitMask == PhysicsCategory.BlockCategory {
            
            let hitBlock = secondBody.node as! SKSpriteNode
            if hero.name == hitBlock.name {
                
                blockDestroyed(hitBlock)
                hitBlock.removeFromParent()
                
                score++
                scoreLabel.text = "\(score)"
                
            }  else {
                
                let ball = firstBody.node as! SKSpriteNode
                ballEnded(ball)
                heroRight.removeFromParent()
                //gameOver()
            }
        }
        
        
        if firstBody.categoryBitMask == PhysicsCategory.HeroRightCategory && secondBody.categoryBitMask == PhysicsCategory.BlockCategory {
            
            let hitBlock = secondBody.node as! SKSpriteNode
            
            if heroRight.name == hitBlock.name {
                
                blockDestroyed(hitBlock)
                hitBlock.removeFromParent()
                
                score++
                
                scoreLabel.text = "\(score)"
                
                
            } else {
                
                let ball = firstBody.node as! SKSpriteNode
                ballEnded(ball)
                hero.removeFromParent()
                //gameOver()
            }
            
        }
        
    }
    
    //MARK:- Update
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        
        if score > 4 {
            
            if isPhaseOne {
                
                removeActionForKey("oneBlock")
                isPhaseOne = false
                
                hero.runAction(SKAction.moveToX(qWidth, duration: 0.7))
                createHeroRight()
            }
        }
        
        deltaTime = CGFloat(currentTime - lastUpdate)
        lastUpdate = currentTime
        
        if deltaTime > 1 {
            
            deltaTime = 0.16
        }
        
        
        if isStarted {
            
            for index in 0...1 {
                
                moveParallaxLayer(parallax[index], speed: parallaxSpeed[index])
            }
        }
        
    }
    
    //MARK:- Gamecenter
    
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
    
    //send high score to leaderboard
    func saveHighscore(score:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "CC_Leaderboard_1") //leaderboard id here
            
            scoreReporter.value = Int64(score) //score variable here (same as above)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError?) -> Void in
                if error != nil {
                    print("error")                }
            })
            
        }
        
    }
    
    //shows leaderboard screen
    func showLeader() {
        var vc = self.view?.window?.rootViewController
        var gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    //hides leaderboard screen
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }

    
}
