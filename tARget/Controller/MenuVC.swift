//
//  GameVC.swift
//  tARget
//
//  Created by ElectroZone on 2018-01-16.
//  Copyright © 2018 ElectroZone. All rights reserved.
//

import UIKit
import ARKit
import GameKit


class MenuVC: UIViewController, GKGameCenterControllerDelegate {
    
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var highScoreLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var instructionButton: UIButton!
    
    
    
    var highScore: Int = 0
    var targetSound: SCNAudioSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        highScoreLbl.text = "High Score: 0"
        var highScoreDefault = UserDefaults.standard
        if highScoreDefault.value(forKey: "highScoreKey") != nil {
            highScore = highScoreDefault.value(forKey: "highScoreKey") as! Int
            highScoreLbl.text = "High Score: \(highScore)"
            authPlayer()
        }
    }
    
    //Instruction pop-up alert
    @IBAction func instructionMessage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Instructions", message: "Look around and tap on targets to get points!", preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Got it!", style: .default, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(restartAction)
        present(alert, animated: true, completion: nil)
    }
  
    //Open Game Center
    @IBAction func callGC(_ sender: UIButton) {
        saveHighScore(number: highScore)
        showLeaderboard()
    }
    
    func authPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            (view, error) in
            
            if view != nil {
                self.present(view!, animated: true, completion: nil)
            } else {
                print(GKLocalPlayer.localPlayer().isAuthenticated)
            }
        }
    }
    
    //Send high score to gc
    func saveHighScore(number: Int) {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: "Touch_tARget_leaderboard")
            scoreReporter.value = Int64(number)
            let scoreArray : [GKScore] = [scoreReporter]
            GKScore.report(scoreArray, withCompletionHandler: nil)
        }
    }
    
    //GC appear
    func showLeaderboard() {
        let viewController = self.view.window?.rootViewController
        let gcvc = GKGameCenterViewController()
        gcvc.gameCenterDelegate = self
        viewController?.present(gcvc, animated: true, completion: nil)
    }
    
    //Dismiss
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}
