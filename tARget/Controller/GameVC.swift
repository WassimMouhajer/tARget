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


class GameVC: UIViewController, GKGameCenterControllerDelegate {
    
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var highScoreLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var finalScoreLbl: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var qualityLbl: UILabel!
    @IBOutlet weak var instructionButton: UIButton!
    
    let configuration = ARWorldTrackingConfiguration()
    var score: Int = 0
    var seconds: Int = 60
    var timer = Timer()
    var highScore: Int = 0
    var targetSound: SCNAudioSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qualityLbl.isHidden = true
        startButton.isHidden = false
        timerLbl.isHidden = true
        scoreLbl.isHidden = true
        resetButton.isHidden = true
        finalScoreLbl.isHidden = true
        titleLbl.isHidden = false
        highScoreLbl.isHidden = false
        leaderboardButton.isHidden = false
        instructionButton.isHidden = false
        highScoreLbl.text = "High Score: 0"
        timerLbl.text = "Time: 1:00"
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        var highScoreDefault = UserDefaults.standard
        if highScoreDefault.value(forKey: "highScoreKey") != nil {
            highScore = highScoreDefault.value(forKey: "highScoreKey") as! Int
            highScoreLbl.text = "High Score: \(highScore)"
            authPlayer()
        }
        targetSound = SCNAudioSource(fileNamed: "Blop.mp3")
        targetSound.load()
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
    
    //Start Game
    @IBAction func startGame(_ sender: UIButton) {
        timerLbl.isHidden = false
        scoreLbl.isHidden = false
        titleLbl.isHidden = true
        highScoreLbl.isHidden = true
        startButton.isHidden = true
        leaderboardButton.isHidden = true
        instructionButton.isHidden = true
        updateUI()
        addNode()
        gameTimer()
    }
    
    //Target node
    func addNode() {
        let targetScene = SCNScene(named: "art.scnassets/target.scn")
        let targetNode = targetScene?.rootNode.childNode(withName: "target", recursively: false)
        targetNode?.position = SCNVector3(randomNumber(firstNum: -1, secondNum: 1), randomNumber(firstNum: -0.5, secondNum: 0.5), randomNumber(firstNum: -1, secondNum: 1))
        self.sceneView.scene.rootNode.addChildNode(targetNode!)
    }
    
    //When you touch scene
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            
        } else {
            let results = hitTest.first!
            let node = results.node
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
            addNode()
            score += 1
            updateUI()
            playTargetSound(toNode: node)
        }
    }
    
    //UI updater
    func updateUI() {
        scoreLbl.text = "Score: \(score)"
        finalScoreLbl.text = "Score: \(score)"
        if score > highScore {
            highScore = score
            highScoreLbl.text = "High Score: \(highScore)"
            var highScoreDefault = UserDefaults.standard
            highScoreDefault.setValue(highScore, forKey: "highScoreKey")
            highScoreDefault.synchronize()
        }
    }
    
    //Reseting the score and timer
    @IBAction func resetGame(_ sender: UIButton) {
        score = 0
        seconds = 60
        viewDidLoad()
    }
    
    //Timer
    func gameTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameVC.counter), userInfo: nil, repeats: true)
    }
    
    //What happens during the timer
    @objc func counter() {
        seconds -= 1
        timerLbl.text = "Time: \(seconds)"
        if seconds == 0 {
            finalScoreLbl.isHidden = false
            resetButton.isHidden = false
            timerLbl.text = "Time is over!"
            timer.invalidate()
            sceneView.session.pause()
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                node.removeFromParentNode()
            }
        }
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
    
    //Play sound
    func playTargetSound(toNode node: SCNNode) {
        node.runAction(SCNAction.playAudio(targetSound, waitForCompletion: false))
    }
    
    //Randomizer
    func randomNumber(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
}
