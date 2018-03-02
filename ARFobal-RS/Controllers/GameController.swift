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
  @IBOutlet weak var shootButton: UIButton!
  @IBOutlet weak var goalLabel: UILabel!
  @IBOutlet weak var targetView: UIView!
  @IBOutlet weak var shootingControlsView: UIView!
  @IBOutlet weak var verticalArrowImageView: UIImageView!
  
  private var field: Field?
  private var goal: Goal?
  private var ball: Ball?
  private var currentScenario: ScenarioPrefab?
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
    
    let transfrom = CGAffineTransform.identity.rotated(by: CGFloat(GLKMathDegreesToRadians(90)))
    verticalArrowImageView.transform = transfrom
    
//    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, .showPhysicsShapes]
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
    
    sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
  }
  
  //MARK: Actions
  
  func registerGestureRecognizers() {
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
    self.sceneView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc func tapped(recognizer: UIGestureRecognizer) {
    setBall()
  }
  
  func setBall(){
    if goalPlaced {
      madeGoal = false
      ball?.state = .placed
      ball?.removeFromParentNode()
      ball?.ballNode?.removeFromParentNode()
      ball = Ball(goalScale: goalScale * 200)
      currentScenario?.ball = ball!
      
      ball!.ballNode!.position = currentScenario!.ballInitialPosition
      scenarioNode!.addChildNode(ball!.ballNode!)
    }
  }
  
  @IBAction func shoot(_ sender: Any) {
    if ball?.state == .shot || ball?.state == .resting {
        return
    }
    
    ball?.state = .shot
    
    ballIsResting = false
    
    guard let currentFrame = self.sceneView.session.currentFrame, ball != nil else {
      return
    }
    let force = simd_make_float4(0, 0, -intensitySlider.value, 0)
    let rotatedForce = simd_mul(currentFrame.camera.transform, force)
    let vectorForce = SCNVector3(rotatedForce.x, angleSlider.value, rotatedForce.z)
    ball!.ballNode!.physicsBody?.applyForce(vectorForce, asImpulse: false)
  }
  
  @IBAction func reset(_ sender: Any) {
    goal?.goalNode?.removeFromParentNode()
    ball?.ballNode?.removeFromParentNode()
    field?.removeFromParentNode()
    scenarioNode?.removeFromParentNode()
    
    field = nil
    scenarioNode = nil
    
    goalPlaced = false
    
    targetView.isHidden = false
    shootingControlsView.isHidden = true
    
    setSceneConf()
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
    
    if !checkPlaneDimensionsAreValid(planeAnchor: planeAnchor) {
      // TODO: animate size requirement text
      return
    }
    
    //Add field
    let plane = Field(anchor: planeAnchor)
    field = plane
    node.addChildNode(plane)
    
    DispatchQueue.main.async {
      self.targetView.isHidden = true
      self.shootingControlsView.isHidden = false
    }
    
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    if let fieldAnchor = anchor as? ARPlaneAnchor {
      if checkPlaneDimensionsAreValid(planeAnchor: fieldAnchor) {
        if field != nil && field?.anchorPoint.identifier == anchor.identifier {
          field?.update(anchor: fieldAnchor)
          goal!.goalNode!.position = SCNVector3(fieldAnchor.center.x, 0, fieldAnchor.center.z + fieldAnchor.extent.z / 3.0)
          scenarioNode!.position = goal!.goalNode!.position
          if ball?.state == .placed {
            setBall()
          }
        } else {
          field = Field(anchor: fieldAnchor)
          node.addChildNode(field!)
          
          //place goal
          let worldPos = SCNVector3(fieldAnchor.transform.columns.3.x + fieldAnchor.center.x, fieldAnchor.transform.columns.3.y + fieldAnchor.center.y, fieldAnchor.transform.columns.3.y + fieldAnchor.center.z)
          let distance = GLKVector3Distance(SCNVector3ToGLKVector3(worldPos), SCNVector3ToGLKVector3(sceneView.pointOfView!.presentation.worldPosition))
          goal = Goal(distance: CGFloat(distance), worldPosition: worldPos, sceneView: sceneView)
          field!.addChildNode(goal!.goalNode!)
          goal!.goalNode!.position = SCNVector3(fieldAnchor.center.x, 0, fieldAnchor.center.z + fieldAnchor.extent.z / 4.0)
          
          goal?.setupGoalkeeper()
          goalScale = Float(distance * 0.002)
          
          currentScenario = Scenario1()
          if scenarioNode == nil {
            scenarioNode = SCNNode()
            scenarioNode?.scale = goal!.goalNode!.scale
            scenarioNode?.constraints = goal?.goalNode?.constraints
            field!.addChildNode(scenarioNode!)
            scenarioNode!.position = goal!.goalNode!.position
          }
          
          currentScenario?.setup(scenarioNode: scenarioNode!, goalScale: goalScale)
          
          goalPlaced = true
          
          setBall()
          
          DispatchQueue.main.async {
            self.targetView.isHidden = true
            self.shootingControlsView.isHidden = false
            self.intensitySlider.maximumValue = distance * 200
            self.angleSlider.maximumValue = distance * 200
          }
        }
      } else {
        // TODO: animate size requirement text
      }
    }
  }
  
  func checkPlaneDimensionsAreValid(planeAnchor: ARPlaneAnchor) -> Bool {
    if (planeAnchor.extent.x > 1.0 && planeAnchor.extent.z > 1.6) ||
      (planeAnchor.extent.x > 1.6 && planeAnchor.extent.z > 1.0) {
      return true
    } else {
      return false
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
        sceneView.scene.addParticleSystem(explosion, transform: translationMatrix)
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
          setBall()
        }
    }
}
