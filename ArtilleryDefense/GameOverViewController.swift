//
//  GameOverViewController.swift
//  ArtilleryDefense
//
//  Created by Andreas Umbach on 25.09.2015.
//  Copyright © 2015 Andreas Umbach. All rights reserved.
//

import UIKit

class GameOverViewController : UIViewController
{
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    var score : Int = 0
    var highscore : Int = 0
    
    override func viewDidLoad() {
        self.scoreLabel.text = "Your Score: \(score)"
        self.highScoreLabel.text = "High Score: \(highscore)"
    }
}
