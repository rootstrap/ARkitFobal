//
//  GameController.swift
//  ARFobal-RS
//
//  Created by Pablo Malvasio on 9/7/17.
//  Copyright © 2017 Rootstrap. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameController: UIViewController {
  
  @IBOutlet var sceneView: ARSCNView!
  
  var planes: [Field] = []
  var goal: Goal?
  var ball: Ball?
  var goalScale: Float = 1.0
  
  var goalPlaced = false
  
  //MARK; Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    registerGestureRecognizers()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setSceneConf()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    sceneView.session.pause()
  }
  
  //MARK: Setup
  func setSceneConf() {
    sceneView.delegate = self
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    
    sceneView.session.run(configuration)
    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
  }
  
  //MARK: Actions
  
  func registerGestureRecognizers() {
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
    self.sceneView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc func tapped(recognizer: UIGestureRecognizer) {
    
    if let sceneView = recognizer.view as? ARSCNView {
      
      let touchLocation = recognizer.location(in: sceneView)
      let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
      
      if !hitTestResult.isEmpty {
        
        guard let hitResult = hitTestResult.first else {
          return
        }
        
        if !goalPlaced {
          goal = Goal(hitResult: hitResult, sceneView: sceneView)
          sceneView.scene.rootNode.addChildNode(goal!)
          goalScale = Float(hitResult.distance*0.002)
          goalPlaced = true
          sceneView.session.run(ARWorldTrackingConfiguration())
        } else {
          ball?.removeFromParentNode()
          ball = Ball(hitResult: hitResult, sceneView: sceneView, goalScale: goalScale)
          sceneView.scene.rootNode.addChildNode(ball!)
        }
      }
    }
  }
  
  @IBAction func shoot(_ sender: Any) {
    guard let currentFrame = self.sceneView.session.currentFrame, ball != nil else {
      return
    }
    let force = simd_make_float4(0, 0, -10.2, 0)
    let rotatedForce = simd_mul(currentFrame.camera.transform, force)
    let vectorForce = SCNVector3(rotatedForce.x, 0, rotatedForce.z)
    ball!.physicsBody?.applyForce(vectorForce, asImpulse: false)
  }
}

extension GameController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
    //Check if the detection is a new anchor for planes
    guard anchor is ARPlaneAnchor else { return }
    
    //Add field
    if let planeAnchor = anchor as? ARPlaneAnchor {
      let plane = Field(anchor: planeAnchor)
      planes.append(plane)
      node.addChildNode(plane)
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    
    let plane = planes.filter { $0.anchorPoint.identifier == anchor.identifier }.first
    if let planeAnchor = anchor as? ARPlaneAnchor {
      plane?.update(anchor: planeAnchor)
    }
  }
}
