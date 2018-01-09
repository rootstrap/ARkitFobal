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
  
  private var field: Field?
  private var goal: Goal?
  private var ball: Ball?
  var goalScale: Float = 1.0
  
  var goalPlaced = false
  
  //MARK; Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, SCNDebugOptions.showPhysicsShapes]
    sceneView.delegate = self
    sceneView.showsStatistics = true;
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
        goalScale = Float(hitResult.distance * 0.002)
        goalPlaced = true
        intensitySlider.maximumValue = Float(hitResult.distance * 200)
        angleSlider.maximumValue = Float(hitResult.distance * 200)
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

/**
 Called when a new node has been mapped to the given anchor.
 @param renderer The renderer that will render the scene.
 @param node The node that maps to the anchor.
 @param anchor The added anchor.
 */
extension GameController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    if field != nil {
        return
    }
    
    //Check if the detection is a new anchor for planes
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
    //Add field
    let plane = Field(anchor: planeAnchor)
    field = plane
    node.addChildNode(plane)
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    if field?.anchorPoint.identifier == anchor.identifier, let fieldAnchor = anchor as? ARPlaneAnchor{
        field?.update(anchor: fieldAnchor)
    }
  }
}

extension GameController: SCNPhysicsContactDelegate {
  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {

    if(contact.nodeA.name == "ball"  || contact.nodeB.name == "ball") && (contact.nodeA.name == "GoalLinePlane"  || contact.nodeB.name == "GoalLinePlane"){
        createExplosion(position: contact.contactPoint, rotation: (ball?.ballNode?.presentation.rotation)!)
        
        ball?.ballNode?.removeFromParentNode()
        ball?.removeFromParentNode()
    }
  }
    
    func createExplosion(position: SCNVector3, rotation: SCNVector4) {
        let explosion = SCNParticleSystem(named: "Goal Particle System", inDirectory: nil)!
        
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z)
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
        sceneView.scene.addParticleSystem(explosion, transform: transformMatrix)
    }
}
