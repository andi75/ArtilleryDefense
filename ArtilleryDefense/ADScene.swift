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
    
    var lasttouch : CGPoint = CGPointMake(0, 0)

    var rotationScale : CGFloat = 0.01
    var minAngle : CGFloat = CGFloat(1.5 / 18.0 * M_PI)
    var maxAngle : CGFloat = CGFloat(8.5 / 18.0 * M_PI)
    
    var lastEnemyTime : NSTimeInterval = 0
    var minEnemyTime : NSTimeInterval = 0.1
    var maxEnemyTime : NSTimeInterval = 3.0
    var nextEnemyTime : NSTimeInterval = 0
    
    var enemyRadius : CGFloat = 6
    
    var maxShellCount = 3
    var currentShellCount = 0
    
    var life = 3
    var score = 0
    
    override func didMoveToView(view: SKView) {
        self.size = view.frame.size
        self.backgroundColor = UIColor.blackColor()
        
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        self.physicsWorld.contactDelegate = self
        
        let ground = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(self.size.width + 2 * enemyRadius, groundHeight))
        ground.name = "Ground"

        ground.position = CGPointMake(self.size.width / 2, groundHeight / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = 8
        ground.physicsBody?.contactTestBitMask = 0
        self.addChild(ground)
        
        let cannon = SKShapeNode(circleOfRadius: cannonRadius)
        cannon.name = "Cannon"

        cannon.fillColor = UIColor.grayColor()
        cannon.position = CGPointMake(cannonOffset + cannonRadius, groundHeight)
        cannon.physicsBody = SKPhysicsBody(circleOfRadius: cannonRadius)
        cannon.physicsBody?.dynamic = false
        cannon.physicsBody?.categoryBitMask = 1
        cannon.physicsBody?.contactTestBitMask = 0
        self.addChild(cannon)
        
        let barrel = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(barrelLength, barrelDiameter))
        barrel.name = "Barrel"

        barrel.anchorPoint = CGPointMake(-cannonRadius / barrelLength, 0.5)
        barrel.position = cannon.position
        barrel.zRotation = CGFloat(M_PI / 4)
        self.addChild(barrel)
        
        let liveLabel = SKLabelNode(text: "Leben")
        liveLabel.name = "LiveLabel"
        liveLabel.fontSize = 16
        liveLabel.position = CGPointMake(40, self.size.height - 40)
        self.addChild(liveLabel)
        
        let scoreLabel = SKLabelNode(text: "Score")
        scoreLabel.name = "ScoreLabel"
        scoreLabel.fontSize = 16
        scoreLabel.position = CGPointMake(40, self.size.height - 60)
        self.addChild(scoreLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches
        {
            lasttouch = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let barrel = self.childNodeWithName("Barrel")!
        
        for touch in touches
        {
            let currenttouch = touch.locationInNode(self)
            barrel.zRotation += (currenttouch.y - lasttouch.y) * rotationScale
            barrel.zRotation = max( min(barrel.zRotation, maxAngle), minAngle )
            lasttouch = currenttouch
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(currentShellCount < maxShellCount)
        {
            // print(currentShellCount)
            currentShellCount++
            fireShot()
        }
    }
    
    func fireShot()
    {
        let barrel = self.childNodeWithName("Barrel")!
        let cannon = self.childNodeWithName("Cannon")!
        
        let shell = SKShapeNode(circleOfRadius: barrelDiameter / 2)
        shell.name = "Shell"
        shell.fillColor = UIColor.redColor()
        shell.strokeColor = UIColor.redColor()
        
        shell.position = CGPointMake(
            cannon.position.x +
                (cannonRadius + barrelLength) * cos(barrel.zRotation),
            cannon.position.y +
                (cannonRadius + barrelLength) * sin(barrel.zRotation)
        )
        
        shell.physicsBody = SKPhysicsBody(circleOfRadius: barrelDiameter / 2)
        shell.physicsBody?.velocity = CGVectorMake(shellSpeed * cos(barrel.zRotation), shellSpeed * sin(barrel.zRotation))
        
        shell.physicsBody?.categoryBitMask = 2
        shell.physicsBody?.contactTestBitMask = 4 + 8
        
        self.addChild(shell)
    }

    func blowUp(node: SKNode)
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
            currentShellCount--
        }
        
        node.removeFromParent()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
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
            score++
        }
        if(
            (contact.bodyA.node!.name == "Cannon" &&
                contact.bodyB.node!.name == "Enemy") ||
                (contact.bodyA.node!.name == "Enemy" &&
                    contact.bodyB.node!.name == "Cannon")
            )
        {
            life--
            if(life <= 0)
            {
                self.viewController?.performSegueWithIdentifier("GameOverSegue", sender: nil)
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

        enemy.fillColor = UIColor.greenColor()
        enemy.position = CGPointMake(
            self.size.width + enemyRadius,
            groundHeight + enemyRadius + 30 * h * enemyRadius)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemyRadius)
        enemy.physicsBody?.categoryBitMask = 4
        enemy.physicsBody?.contactTestBitMask = 1
        enemy.physicsBody?.velocity = CGVectorMake(-80, 0)
        enemy.physicsBody?.linearDamping = 0
        enemy.physicsBody?.friction = 0
        enemy.physicsBody?.restitution = 1
        self.addChild(enemy)
    }
    
    func updateLabels()
    {
        let liveLabel = self.childNodeWithName("LiveLabel") as! SKLabelNode
        let scoreLabel = self.childNodeWithName("ScoreLabel") as! SKLabelNode
        
        liveLabel.text = "Lives: \(life)"
        scoreLabel.text = "Score: \(score)"
    }
    
    override func update(currentTime: NSTimeInterval) {
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
