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
    
    if let scene = SCNScene(named: "art.scnassets/soccer-goal/goal.dae"),
      let node = scene.rootNode.childNode(withName: "goal", recursively: true), let goalNode2 = scene.rootNode.childNode(withName: "ID85", recursively: true) {
      
      goalNode = node
      
      let distance = hitResult.distance
      goalNode?.scale = SCNVector3(distance*0.002, distance*0.002, distance*0.002)
      
      goalNode?.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
      
      goalNode?.constraints = [SCNLookAtConstraint(target: currentPlace)]
      
      let goalShape = SCNPhysicsShape(node: goalNode!, options: [ .type: SCNPhysicsShape.ShapeType.concavePolyhedron, .scale: distance*0.002])
      let goal2Shape = SCNPhysicsShape(geometry: goalNode2.geometry!, options: [ .type: SCNPhysicsShape.ShapeType.concavePolyhedron, .scale: distance*0.002])
      let body = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: goalShape)
      body.categoryBitMask = BodyType.goal.rawValue
      body.contactTestBitMask = BodyType.ball.rawValue
      body.mass = 15
      body.friction = 1
      let body2 = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: goal2Shape)
      body2.categoryBitMask = BodyType.goal.rawValue
      body2.contactTestBitMask = BodyType.ball.rawValue

      goalNode!.physicsBody = body
      //goalNode2.physicsBody = body
      
      self.addChildNode(goalNode!)
    }

  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
