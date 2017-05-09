//
//  ADScene.swift
//  ArtilleryDefense
//
//  Created by Andreas Umbach on 24.09.2015.
//  Copyright © 2015 Andreas Umbach. All rights reserved.
//

import SpriteKit

class ADScene : SKScene, SKPhysicsContactDelegate
{
    var viewController : UIViewController? = nil
    
    var groundHeight : CGFloat = 50
    var cannonRadius : CGFloat = 30
    var cannonOffset : CGFloat = 15
    
    var barrelLength : CGFloat = 40
    var barrelDiameter : CGFloat = 8
    
    var shellSpeed : CGFloat = 440
    
    var lasttouch : CGPoint = CGPoint(x: 0, y: 0)

    var rotationScale : CGFloat = 0.01
    var minAngle : CGFloat = 1.5 / 18.0 * .pi
    var maxAngle : CGFloat = 8.5 / 18.0 * .pi
    
    var lastEnemyTime : TimeInterval = 0
    var minEnemyTime : TimeInterval = 0.1
    var maxEnemyTime : TimeInterval = 3.0
    var nextEnemyTime : TimeInterval = 0
    
    var enemyRadius : CGFloat = 6
    
    var maxShellCount = 3
    var currentShellCount = 0
    
    var life = 3
    var score = 0
    var highscore = 0
    
    override func didMove(to view: SKView) {
        self.size = view.frame.size
        self.backgroundColor = UIColor.black
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        self.physicsWorld.contactDelegate = self
        
        let ground = SKSpriteNode(color: UIColor.white, size: CGSize(width: self.size.width + 2 * enemyRadius, height: groundHeight))
        ground.name = "Ground"

        ground.position = CGPoint(x: self.size.width / 2, y: groundHeight / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = 8
        ground.physicsBody?.contactTestBitMask = 0
        self.addChild(ground)
        
        let cannon = SKShapeNode(circleOfRadius: cannonRadius)
        cannon.name = "Cannon"

        cannon.fillColor = UIColor.gray
        cannon.position = CGPoint(x: cannonOffset + cannonRadius, y: groundHeight)
        cannon.physicsBody = SKPhysicsBody(circleOfRadius: cannonRadius)
        cannon.physicsBody?.isDynamic = false
        cannon.physicsBody?.categoryBitMask = 1
        cannon.physicsBody?.contactTestBitMask = 0
        self.addChild(cannon)
        
        let barrel = SKSpriteNode(color: UIColor.blue, size: CGSize(width: barrelLength, height: barrelDiameter))
        barrel.name = "Barrel"

        barrel.anchorPoint = CGPoint(x: -cannonRadius / barrelLength, y: 0.5)
        barrel.position = cannon.position
        barrel.zRotation = .pi / 4
        self.addChild(barrel)
        
        let liveLabel = SKLabelNode(text: "Leben")
        liveLabel.name = "LiveLabel"
        liveLabel.fontSize = 16
        liveLabel.position = CGPoint(x: 10, y: self.size.height - 40)
        liveLabel.horizontalAlignmentMode = .left
        self.addChild(liveLabel)
        
        let scoreLabel = SKLabelNode(text: "Score")
        scoreLabel.name = "ScoreLabel"
        scoreLabel.fontSize = 16
        scoreLabel.position = CGPoint(x: 10, y: self.size.height - 60)
        scoreLabel.horizontalAlignmentMode = .left
        self.addChild(scoreLabel)
        
        let highscoreLabel = SKLabelNode(text: "Highscore")
        highscoreLabel.name = "HighscoreLabel"
        highscoreLabel.fontSize = 16
        highscoreLabel.position = CGPoint(x: 10, y: self.size.height - 80)
        highscoreLabel.horizontalAlignmentMode = .left
        self.addChild(highscoreLabel)

        updateHighscore()
    }
    
    func updateHighscore()
    {
        let defaults = UserDefaults()
        highscore = defaults.integer(forKey: "ADSceneHighScore")
        if(score > highscore)
        {
            highscore = score
            defaults.set(highscore, forKey: "ADSceneHighScore")
            defaults.synchronize()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            lasttouch = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let barrel = self.childNode(withName: "Barrel")!
        
        for touch in touches
        {
            let currenttouch = touch.location(in: self)
            barrel.zRotation += (currenttouch.y - lasttouch.y) * rotationScale
            barrel.zRotation = max( min(barrel.zRotation, maxAngle), minAngle )
            lasttouch = currenttouch
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(currentShellCount < maxShellCount)
        {
            // print(currentShellCount)
            currentShellCount += 1
            fireShot()
        }
    }
    
    func fireShot()
    {
        let barrel = self.childNode(withName: "Barrel")!
        let cannon = self.childNode(withName: "Cannon")!
        
        let shell = SKShapeNode(circleOfRadius: barrelDiameter / 2)
        shell.name = "Shell"
        shell.fillColor = UIColor.red
        shell.strokeColor = UIColor.red
        
        shell.position = CGPoint(
            x: cannon.position.x +
                (cannonRadius + barrelLength) * cos(barrel.zRotation),
            y: cannon.position.y +
                (cannonRadius + barrelLength) * sin(barrel.zRotation)
        )
        
        shell.physicsBody = SKPhysicsBody(circleOfRadius: barrelDiameter / 2)
        shell.physicsBody?.velocity = CGVector(dx: shellSpeed * cos(barrel.zRotation), dy: shellSpeed * sin(barrel.zRotation))
        
        shell.physicsBody?.categoryBitMask = 2
        shell.physicsBody?.contactTestBitMask = 4 + 8
        
        self.addChild(shell)
    }

    func blowUp(_ node: SKNode)
    {
        // check if node is still in sceneGraph
        if(node.parent != self)
        {
            return
        }
        // print("blowing up \(node.name)")
        
        let boom = SKEmitterNode(fileNamed: "ShellExplosion.sks")
        boom?.position = node.position
        
        self.addChild(boom!)
        
        if(node.name == "Shell")
        {
            currentShellCount -= 1
        }
        
        node.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if(contact.bodyA.node == nil || contact.bodyB.node == nil)
        {
            return
        }
        // print("\(contact.bodyA.node!.name!) => \(contact.bodyB.node!.name!)")
        
        if(
            (contact.bodyA.node!.name == "Shell" &&
                contact.bodyB.node!.name == "Enemy") ||
                (contact.bodyA.node!.name == "Enemy" &&
                    contact.bodyB.node!.name == "Shell")
            )
        {
            score += 1
            updateHighscore()
        }
        if(
            (contact.bodyA.node!.name == "Cannon" &&
                contact.bodyB.node!.name == "Enemy") ||
                (contact.bodyA.node!.name == "Enemy" &&
                    contact.bodyB.node!.name == "Cannon")
            )
        {
            life -= 1
            if(life <= 0)
            {
                self.viewController?.performSegue(withIdentifier: "GameOverSegue", sender: nil)
            }
        }
        
        if(
            (contact.bodyA.node!.name == "Shell") ||
                (contact.bodyA.node!.name == "Enemy")
            )
        {
            blowUp(contact.bodyA.node!)
        }
        if(
            (contact.bodyB.node!.name == "Shell") ||
                (contact.bodyB.node!.name == "Enemy")
            )
        {
            blowUp(contact.bodyB.node!)
        }
    }
    
    func spawnEnemy()
    {
        let enemy = SKShapeNode(circleOfRadius: enemyRadius)
        enemy.name = "Enemy"
        
        let h = CGFloat(arc4random() % 4) / 4.0

        enemy.fillColor = UIColor.green
        enemy.position = CGPoint(
            x: self.size.width + enemyRadius,
            y: groundHeight + enemyRadius + 30 * h * enemyRadius)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemyRadius)
        enemy.physicsBody?.categoryBitMask = 4
        enemy.physicsBody?.contactTestBitMask = 1
        enemy.physicsBody?.velocity = CGVector(dx: -80, dy: 0)
        enemy.physicsBody?.linearDamping = 0
        enemy.physicsBody?.friction = 0
        enemy.physicsBody?.restitution = 1
        self.addChild(enemy)
    }
    
    func updateLabels()
    {
        let liveLabel = self.childNode(withName: "LiveLabel") as! SKLabelNode
        let scoreLabel = self.childNode(withName: "ScoreLabel") as! SKLabelNode
        let highscoreLabel = self.childNode(withName: "HighscoreLabel") as! SKLabelNode
        
        liveLabel.text = "Lives: \(life)"
        scoreLabel.text = "Score: \(score)"
        highscoreLabel.text = "Highscore: \(highscore)"
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateLabels()
        
        if(lastEnemyTime == 0)
        {
            lastEnemyTime = currentTime
        }
        
        let dt = currentTime - lastEnemyTime
        if(dt > nextEnemyTime)
        {
            let r = Double(arc4random() % 128) / 128.0
            nextEnemyTime = r * (maxEnemyTime - minEnemyTime)
//            print("spawning enemy after \(dt) seconds, next one at = \(nextEnemyTime)")
            spawnEnemy()
            lastEnemyTime = currentTime
        }
    }
    
}
