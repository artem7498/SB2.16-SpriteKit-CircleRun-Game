//
//  GameViewController.swift
//  SB2.16 SpriteKit CircleRun Game
//
//  Created by Артём on 4/8/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.frame.size)
        let skView = view as! SKView
        skView.presentScene(scene)
        
    }

}
