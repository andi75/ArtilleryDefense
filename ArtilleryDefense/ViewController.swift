//
//  ViewController.swift
//  ArtilleryDefense
//
//  Created by Andreas Umbach on 24.09.2015.
//  Copyright © 2015 Andreas Umbach. All rights reserved.
//

import SpriteKit

class ViewController: UIViewController {

    var scene : ADScene? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scene = ADScene()
        scene!.viewController = self
        (self.view as! SKView).presentScene(scene)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let gameOverVC = segue.destinationViewController as! GameOverViewController
        gameOverVC.score = scene!.score
        gameOverVC.highscore = scene!.highscore
    }
}

