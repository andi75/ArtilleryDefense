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
    var ground : SKSpriteNode? = nil
    var cannon : SKShapeNode? = nil
    var barrel : SKSpriteNode? = nil
    var shell : SKShapeNode? = nil
    
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
    
    override func didMoveToView(view: SKView) {
        self.size = view.frame.size
        self.backgroundColor = UIColor.blackColor()
        
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        
        self.physicsWorld.contactDelegate = self
        
        ground = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(self.size.width, groundHeight))
        //ground?.anchorPoint = CGPointMake(0, 0)
        //ground?.position = CGPointMake(0, 0)
        ground?.position = CGPointMake(self.size.width / 2, groundHeight / 2)
        ground?.physicsBody = SKPhysicsBody(rectangleOfSize: ground!.size)
        ground?.physicsBody?.dynamic = false
        
        ground?.physicsBody?.categoryBitMask = 1
        
        
        self.addChild(ground!)
        
        cannon = SKShapeNode(circleOfRadius: cannonRadius)
        cannon?.fillColor = UIColor.redColor()
        cannon?.position = CGPointMake(cannonOffset + cannonRadius, groundHeight)
        cannon?.physicsBody = SKPhysicsBody(circleOfRadius: cannonRadius)
        cannon?.physicsBody?.dynamic = false
        self.addChild(cannon!)
        
        barrel = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(barrelLength, barrelDiameter))
        barrel?.anchorPoint = CGPointMake(-cannonRadius / barrelLength, 0.5)
        barrel?.position = cannon!.position
        barrel?.zRotation = CGFloat(M_PI / 4)
        self.addChild(barrel!)
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches
        {
            lasttouch = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches
        {
            let currenttouch = touch.locationInNode(self)
            barrel!.zRotation += (currenttouch.y - lasttouch.y) * rotationScale
            barrel!.zRotation = max( min(barrel!.zRotation, maxAngle), minAngle )
            lasttouch = currenttouch
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // if(shell == nil)
        if(true)
        {
            shell = SKShapeNode(circleOfRadius: barrelDiameter / 2)
            shell?.fillColor = UIColor.greenColor()
            shell?.position = CGPointMake(
                cannon!.position.x +
                    (cannonRadius + barrelLength) * cos(barrel!.zRotation),
                cannon!.position.y +
                    (cannonRadius + barrelLength) * sin(barrel!.zRotation)
            )
            
            shell?.physicsBody = SKPhysicsBody(circleOfRadius: barrelDiameter / 2)
            shell?.physicsBody?.velocity = CGVectorMake(shellSpeed * cos(barrel!.zRotation), shellSpeed * sin(barrel!.zRotation))
            
            shell?.physicsBody?.contactTestBitMask = 1
            
            self.addChild(shell!)
        }
    }
    
    func blowUp(node: SKNode)
    {
        let boom = SKEmitterNode(fileNamed: "ShellExplosion.sks")
        boom?.position = node.position
        
        self.addChild(boom!)
        
        node.removeFromParent()
        
        if(node == shell)
        {
            shell = nil
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if(contact.bodyA.contactTestBitMask == 1)
        {
            blowUp(contact.bodyA.node!)
        }
        if(contact.bodyB.contactTestBitMask == 1)
        {
            blowUp(contact.bodyB.node!)
        }
    }
}
