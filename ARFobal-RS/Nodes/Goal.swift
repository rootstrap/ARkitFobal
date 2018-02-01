//
//  Goal.swift
//  ARFobal-RS
//
//  Created by Pablo Malvasio on 9/8/17.
//  Copyright © 2017 Rootstrap. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Goal: SCNNode {
  
  var goalNode: SCNNode?
  
  init(hitResult: ARHitTestResult, sceneView: ARSCNView) {
    super.init()
    
    let camProjection = SCNVector3(sceneView.pointOfView!.position.x, hitResult.worldTransform.columns.3.y, sceneView.pointOfView!.position.z)
    let currentPlace = SCNNode()
    currentPlace.position = camProjection
    
    if let scene = SCNScene(named: "art.scnassets/soccer-goal/goal2.dae"),
      let node = scene.rootNode.childNode(withName: "goal", recursively: true) {
      
      let goalLinePlane = node.childNode(withName: "GoalLinePlane", recursively: true)
        
      goalNode = node
      
      let distance = hitResult.distance
      print("distance: " + String(describing: distance))
      let scale = max(0.00225, distance * 0.0015)
      let scaleVector = SCNVector3(scale, scale, scale)
      print("goal scale: " + String(describing: scale))
      goalNode?.scale = scaleVector
      
      goalNode?.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
      
      goalNode?.constraints = [SCNLookAtConstraint(target: currentPlace)]
      
      let goalShape = SCNPhysicsShape(node: goalNode!, options: [ .type: SCNPhysicsShape.ShapeType.concavePolyhedron, .scale: scale])
      
      let body = SCNPhysicsBody(type: .kinematic, shape: goalShape)
      body.categoryBitMask = BodyType.goal.rawValue
      body.contactTestBitMask = BodyType.ball.rawValue
      body.mass = 15
      body.friction = 1
        
      goalLinePlane?.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        
      let goalLinePhysicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
      goalLinePhysicsBody.categoryBitMask = BodyType.goalLine.rawValue
      goalLinePhysicsBody.collisionBitMask = BodyType.goalLine.rawValue
      goalLinePhysicsBody.contactTestBitMask = BodyType.ball.rawValue
      

      goalNode!.physicsBody = body
      goalLinePlane?.physicsBody = goalLinePhysicsBody
      
      self.addChildNode(goalNode!)
    }

  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
