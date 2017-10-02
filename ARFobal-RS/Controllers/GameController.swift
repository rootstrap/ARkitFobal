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
  @IBOutlet weak var intensitySlider: UISlider!
  @IBOutlet weak var angleSlider: UISlider!
  
  private var planes: [Field] = []
  private var goal: Goal?
  private var ball: Ball?
  var goalScale: Float = 1.0
  
  var goalPlaced = false
  
  //MARK; Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin, SCNDebugOptions.showPhysicsShapes]
    sceneView.delegate = self
    sceneView.scene.physicsWorld.contactDelegate = self
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

    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    
    sceneView.session.run(configuration)
  }
  
  //MARK: Actions
  
  func registerGestureRecognizers() {
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
    self.sceneView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc func tapped(recognizer: UIGestureRecognizer) {
    
    let touchLocation = recognizer.location(in: sceneView)
    let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
    
    if !hitTestResult.isEmpty {
      
      guard let hitResult = hitTestResult.first else {
        return
      }
      
    if !goalPlaced {
        sceneView.session.run(ARWorldTrackingConfiguration())
        goal = Goal(hitResult: hitResult, sceneView: sceneView)
        sceneView.scene.rootNode.addChildNode(goal!.goalNode!)
        goalScale = Float(hitResult.distance*0.002)
        goalPlaced = true
        intensitySlider.maximumValue = Float(hitResult.distance*200)
        angleSlider.maximumValue = Float(hitResult.distance*200)
      } else {
        ball?.removeFromParentNode()
        ball?.ballNode?.removeFromParentNode()
        ball = Ball(goalScale: goalScale)
        ball!.ballNode!.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                              hitResult.worldTransform.columns.3.y + 0.1,
                              hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(ball!.ballNode!)
      }
    }
  }
  
  @IBAction func shoot(_ sender: Any) {
    guard let currentFrame = self.sceneView.session.currentFrame, ball != nil else {
      return
    }
    let force = simd_make_float4(0, 0, -intensitySlider.value, 0)
    let rotatedForce = simd_mul(currentFrame.camera.transform, force)
    let vectorForce = SCNVector3(rotatedForce.x, angleSlider.value, rotatedForce.z)
    ball!.ballNode!.physicsBody?.applyForce(vectorForce, asImpulse: false)
  }
}

extension GameController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
    //Check if the detection is a new anchor for planes
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    //Add field
    let plane = Field(anchor: planeAnchor)
    planes.append(plane)
    node.addChildNode(plane)
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    
    let plane = planes.filter { $0.anchorPoint.identifier == anchor.identifier }.first
    if let planeAnchor = anchor as? ARPlaneAnchor {
      plane?.update(anchor: planeAnchor)
    }
  }
}

extension GameController: SCNPhysicsContactDelegate {
  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {

    print("contact")
  }
}
