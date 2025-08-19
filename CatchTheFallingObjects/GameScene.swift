//
//  GameScene.swift
//  CatchTheFallingObjects
//
//  Created by Şakir Yılmaz ÖĞÜT on 30.07.2025.
//

import SpriteKit

@objcMembers
class GameScene: SKScene {
    
    var scoreLabel = SKLabelNode(text: "Score: 0")
    var highestScoreLabel = SKLabelNode(text: "Highest Score: 0")
    var finalScoreLabel = SKLabelNode(text: "Final Score: 0")
    var timerLabel = SKLabelNode(text: "Time: 0:00")
    
    var gameStartTime: TimeInterval = 0
    var currentGameTime: TimeInterval = 0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var highestScore = 0 {
        didSet {
            highestScoreLabel.text = "Highest Score: \(highestScore)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        // this method is called when your game scene is ready to run
        physicsWorld.gravity = CGVector(dx: 0, dy: -3)
        
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: 450, y: 300) // Score'un altında
        timerLabel.name = "timerLabel"
        timerLabel.fontSize = 35
        addChild(timerLabel)
        
        scoreLabel.fontColor = .white
        scoreLabel.position.y = 280
        scoreLabel.name = "scoreLabel"
        scoreLabel.fontSize = 70
        addChild(scoreLabel)
        score = 0
        
        highestScoreLabel.fontColor = .white
        highestScoreLabel.position.y = 240
        highestScoreLabel.name = "highestScoreLabel"
        highestScoreLabel.fontSize = 30
        addChild(highestScoreLabel)
        highestScore = 0
        
        let background = SKSpriteNode(imageNamed: "background_2")
        background.name = "background"
        background.zPosition = -1
        addChild(background)
        
        
        for i in 1...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i-1) * 0.5) {
                if Bool.random() {
                    self.generateHealthyCollectable()
                } else {
                    self.generateUnhealthyCollectable()
                }
            }
        }
        generateGameEnderCollectable()
        
        let music = SKAudioNode(fileNamed: "PixelAdventures")
        addChild(music)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        guard let tapped = tappedNodes.first else { return }
        
        if tapped.name == "healthyCollectable" {
            self.score += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.generateHealthyCollectable()
            }
            let sound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
            run(sound)
            
            tapped.removeFromParent()
        }
        else if tapped.name == "unhealthyCollectable" {
            self.score -= 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.generateUnhealthyCollectable()
            }
            let sound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
            run(sound)
            
            tapped.removeFromParent()
        }
        else if tapped.name == "gameEnderCollectable" {
            gameOver()
            
            tapped.removeFromParent()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
        
        if gameStartTime == 0 {
            gameStartTime = currentTime
        }
        currentGameTime = currentTime - gameStartTime
        
        let minutes = Int(currentGameTime) / 60
        let seconds = Int(currentGameTime) % 60
        timerLabel.text = String(format: "%d:%02d", minutes, seconds)
        
        for node in children {
            if node.position.y < -400 {
                node.removeFromParent()
                if node.name == "healthyCollectable" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.generateHealthyCollectable()
                        self.score -= 1
                    }
                }
                else if node.name == "unhealthyCollectable" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.generateUnhealthyCollectable()
                    }
                }
                else if node.name == "gameEnderCollectable" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.generateGameEnderCollectable()
                    }
                }
            }
        }
        
        if score > highestScore {
            highestScore = score
        }
        
        if score < -200 {
            gameOver()
        }
        
    }
    
    func gameOver() {
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            for node in self.children {
                if node.name == "scoreLabel" || node.name == "highestScoreLabel" || node.name == "background"  { continue }
                node.removeFromParent()
            }
        }
        
//        scoreLabel.removeFromParent()
//        heighestScoreLabel.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }
    }
    
    func generateHealthyCollectable() {
        let sprites = ["apple", "banana"]
        let spriteName = sprites.randomElement()!
        
        let healthyCollectable = SKSpriteNode(imageNamed: spriteName)
        healthyCollectable.name = "healthyCollectable"
        healthyCollectable.size = CGSize(width: 70, height: 70)
        healthyCollectable.physicsBody = SKPhysicsBody(texture: healthyCollectable.texture!, size: healthyCollectable.size)
        healthyCollectable.physicsBody?.isDynamic = true
        healthyCollectable.physicsBody?.affectedByGravity = true
        healthyCollectable.texture!.filteringMode = .nearest
        healthyCollectable.zPosition = 0
        healthyCollectable.position = CGPoint(x: Double.random(in: -450...450), y: -400)
        addChild(healthyCollectable)
        healthyCollectable.physicsBody?.velocity = CGVector(dx: 0, dy: 700)
    }
    
    func generateUnhealthyCollectable() {
        let sprites = ["donut", "chips"]
        let spriteName = sprites.randomElement()!
        
        let unhealthyCollectable = SKSpriteNode(imageNamed: spriteName)
        unhealthyCollectable.name = "unhealthyCollectable"
        unhealthyCollectable.size = CGSize(width: 70, height: 70)
        unhealthyCollectable.physicsBody = SKPhysicsBody(texture: unhealthyCollectable.texture!, size: unhealthyCollectable.size)
        unhealthyCollectable.physicsBody?.isDynamic = true
        unhealthyCollectable.physicsBody?.affectedByGravity = true
        unhealthyCollectable.texture!.filteringMode = .nearest
        unhealthyCollectable.zPosition = 0
        unhealthyCollectable.position = CGPoint(x: Double.random(in: -450...450), y: -400)
        addChild(unhealthyCollectable)
        unhealthyCollectable.physicsBody?.velocity = CGVector(dx: 0, dy: 700)
    }
    
    func generateGameEnderCollectable() {
        let sprites = ["burakkara"]
        let spriteName = sprites.randomElement()!
        
        let gameEnderCollectable = SKSpriteNode(imageNamed: spriteName)
        gameEnderCollectable.name = "gameEnderCollectable"
        gameEnderCollectable.size = CGSize(width: 70, height: 70)
        gameEnderCollectable.physicsBody = SKPhysicsBody(texture: gameEnderCollectable.texture!, size: gameEnderCollectable.size)
        gameEnderCollectable.physicsBody?.isDynamic = true
        gameEnderCollectable.physicsBody?.affectedByGravity = true
        gameEnderCollectable.texture!.filteringMode = .nearest
        gameEnderCollectable.zPosition = 0
        gameEnderCollectable.position = CGPoint(x: Double.random(in: -450...450), y: -400)
        addChild(gameEnderCollectable)
        gameEnderCollectable.physicsBody?.velocity = CGVector(dx: 0, dy: 700)
    }
}
