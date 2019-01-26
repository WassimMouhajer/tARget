//
//  SceneVC.swift
//  tARget
//
//  Created by Wassim Mouhajer on 2019-01-26.
//  Copyright © 2019 ElectroZone. All rights reserved.
//

import UIKit
import ARKit

class SceneVC: UIViewController {

    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var qualityLbl: UILabel!
    @IBOutlet weak var finalScoreLbl: UILabel!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    var score: Int = 0
    var seconds: Int = 60
    var timer = Timer()
    var highScore: Int = 0
    var targetSound: SCNAudioSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qualityLbl.isHidden = true
        resetBtn.isHidden = true
        finalScoreLbl.isHidden = true
        timerLbl.text = "Time: 1:00"
        targetSound = SCNAudioSource(fileNamed: "Blop.mp3")
        targetSound.load()
        setUpAR()
        updateUI()
        addNode()
        gameTimer()
    }
    
    func setUpAR() {
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
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
    
    @objc func counter() {
        seconds -= 1
        timerLbl.text = "Time: \(seconds)"
        if seconds == 0 {
            finalScoreLbl.isHidden = false
            resetBtn.isHidden = false
            timerLbl.text = "Time is over!"
            timer.invalidate()
            sceneView.session.pause()
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                node.removeFromParentNode()
            }
        }
    }
    
    //Target node
    func addNode() {
        let targetScene = SCNScene(named: "art.scnassets/target.scn")
        let targetNode = targetScene?.rootNode.childNode(withName: "target", recursively: false)
        targetNode?.position = SCNVector3(randomNumber(firstNum: -1, secondNum: 1), randomNumber(firstNum: -0.5, secondNum: 0.5), randomNumber(firstNum: -1, secondNum: 1))
        self.sceneView.scene.rootNode.addChildNode(targetNode!)
    }
    
    //Timer
    func gameTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(counter), userInfo: nil, repeats: true)
    }

    //UI updater
    func updateUI() {
        scoreLbl.text = "Score: \(score)"
        finalScoreLbl.text = "Score: \(score)"
        if score > highScore {
            highScore = score
            var highScoreDefault = UserDefaults.standard
            highScoreDefault.setValue(highScore, forKey: "highScoreKey")
            highScoreDefault.synchronize()
        }
    }
    
    //Play sound
    func playTargetSound(toNode node: SCNNode) {
        node.runAction(SCNAction.playAudio(targetSound, waitForCompletion: false))
    }
    
    //Randomizer
    func randomNumber(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    @IBAction func resetGame(_ sender: UIButton) {
        score = 0
        seconds = 60
        viewDidLoad()
    }
    
}
