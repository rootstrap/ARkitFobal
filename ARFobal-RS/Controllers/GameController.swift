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
import Foundation

class GameController: UIViewController {
  
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var intensitySlider: UISlider!
  @IBOutlet weak var angleSlider: UISlider!
  @IBOutlet weak var goalLabel: UILabel!
  @IBOutlet weak var restingLabel: UILabel!
  
  private var field: Field?
  private var goal: Goal?
  private var ball: Ball?
  private var scenarioNode: SCNNode?
  var goalScale: Float = 1.0
  
  var goalPlaced = false
  var madeGoal = false
  var ballIsResting = false
    
  var goalLblOriginRect: CGRect?
    
  var restingVelocityThreshold: SCNVector3 = SCNVector3Make(0.001, 0.001, 0.001)
    
  //MARK; Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.goalLblOriginRect = self.goalLabel.frame
    
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
        goal?.setupGoalkeeper()
        goalScale = Float(hitResult.distance * 0.002)
        
        let scenario1 = Scenario1()
        if scenarioNode == nil {
          scenarioNode = SCNNode()
          scenarioNode?.scale = goal!.goalNode!.scale
          scenarioNode?.position = goal!.goalNode!.position
          scenarioNode?.constraints = goal?.goalNode?.constraints
          sceneView.scene.rootNode.addChildNode(scenarioNode!)
        }
        
        scenario1.setup(scenarioNode: scenarioNode!)
        
        goalPlaced = true
        intensitySlider.maximumValue = Float(hitResult.distance * 200)
        angleSlider.maximumValue = Float(hitResult.distance * 200)
      } else {
        madeGoal = false
        ball?.state = .placed
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
    if ball?.state == .shot || ball?.state == .resting {
        return
    }
    
    ball?.state = .shot
    
    ballIsResting = false
    restingLabel.text = "Not Resting"

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

    if !madeGoal && ((contact.nodeA.name == "GoalLinePlane" && contact.nodeB.name == "ball") || (contact.nodeA.name == "ball" && contact.nodeB.name == "GoalLinePlane")) {
        madeGoal = true
        
        createExplosion(position: contact.contactPoint, rotation: (ball?.ballNode?.presentation.rotation)!)
        
        DispatchQueue.main.async {
            let originFrame = self.goalLabel.frame
            let animator = UIViewPropertyAnimator(duration: 1.2, curve: .linear, animations: {
                self.goalLabel.frame = self.goalLabel.frame.offsetBy(dx: self.view.frame.width + originFrame.width, dy: 0)
            })
            animator.addCompletion({ _ in
                self.goalLabel.frame = self.goalLblOriginRect!
            })
            animator.startAnimation()
        }

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

extension GameController: SCNSceneRendererDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        guard let ballPhysicsBody = ball?.ballNode?.physicsBody else {
            return
        }
        
        let currentVelocity = ballPhysicsBody.velocity
        if ball?.state == .shot &&
            abs(currentVelocity.x) < restingVelocityThreshold.x &&
            abs(currentVelocity.y) < restingVelocityThreshold.y &&
            abs(currentVelocity.z) < restingVelocityThreshold.z {
            ballIsResting = true
            DispatchQueue.main.async{
                self.restingLabel!.text = "Resting"
            }
        }
    }
}
