//
//  ADScene.swift
//  ArtilleryDefense
//
//  Created by Andreas Umbach on 24.09.2015.
//  Copyright © 2015 Andreas Umbach. All rights reserved.
//

import SpriteKit

class ADScene : SKScene
{
    var ground : SKSpriteNode? = nil
    var cannon : SKShapeNode? = nil
    var barrel : SKSpriteNode? = nil
    var shell : SKShapeNode? = nil
    
    var groundHeight : CGFloat = 100
    var cannonRadius : CGFloat = 60
    var cannonOffset : CGFloat = 30
    
    var barrelLength : CGFloat = 40
    var barrelDiameter : CGFloat = 10
    
    var shellSpeed : CGFloat = 500
    
    override func didMoveToView(view: SKView) {
        self.size = view.frame.size
        self.backgroundColor = UIColor.blackColor()
        
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        
        ground = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(self.size.width, groundHeight))
        //ground?.anchorPoint = CGPointMake(0, 0)
        //ground?.position = CGPointMake(0, 0)
        ground?.position = CGPointMake(self.size.width / 2, groundHeight / 2)
        ground?.physicsBody = SKPhysicsBody(rectangleOfSize: ground!.size)
        ground?.physicsBody?.dynamic = false
        self.addChild(ground!)
        
        cannon = SKShapeNode(circleOfRadius: cannonRadius)
        cannon?.fillColor = UIColor.redColor()
        cannon?.position = CGPointMake(cannonOffset + cannonRadius, groundHeight)
        self.addChild(cannon!)
        
        barrel = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(barrelLength, barrelDiameter))
        barrel?.anchorPoint = CGPointMake(-cannonRadius / barrelLength, 0.5)
        barrel?.position = cannon!.position
        barrel?.zRotation = CGFloat(M_PI / 4)
        self.addChild(barrel!)
        
        
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
            self.addChild(shell!)
        }
    }
}
