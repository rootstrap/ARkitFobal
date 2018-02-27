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
  
  init(distance: CGFloat, worldPosition: SCNVector3, sceneView: ARSCNView) {
    super.init()
    
    
    if let scene = SCNScene(named: "art.scnassets/soccer-goal/goal.dae"),
      let node = scene.rootNode.childNode(withName: "goal", recursively: true) {
      
      let goalLinePlane = node.childNode(withName: "GoalLinePlane", recursively: true)
        
      goalNode = node
      
      let scale = max(0.00225, distance * 0.0015)
      let scaleVector = SCNVector3(scale, scale, scale)
      goalNode?.scale = scaleVector
      
      let camProjection = SCNVector3(sceneView.pointOfView!.position.x, worldPosition.y, sceneView.pointOfView!.position.z)
      let currentPlace = SCNNode()
      currentPlace.position = camProjection
      
      //goalNode?.constraints = [SCNLookAtConstraint(target: currentPlace)]
      
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
    }

  }
  
  func setupGoalkeeper() {
    if let scene = SCNScene(named: "art.scnassets/dummy/dummy.dae"),
      let goalkeeperNode = scene.rootNode.childNode(withName: "Dummy", recursively: true) {
      
      let eulerAngles = SCNVector3(0, GLKMathDegreesToRadians(90), 0)
      goalkeeperNode.eulerAngles = eulerAngles
      
      goalNode?.addChildNode(goalkeeperNode)
      
      goalkeeperNode.position = SCNVector3(0, 50, -50)
      
      goalkeeperNode.scale = SCNVector3(10, 10, 10)
      
      goalkeeperNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
      
      let startRight = SCNAction.move(to: SCNVector3(100, 50, -50), duration: 1.5)
      let moveLeft = SCNAction.move(to: SCNVector3(-100, 50, -50), duration: 3.0)
      let moveRight = SCNAction.move(to: SCNVector3(100, 50, -50), duration: 3.0)
      goalkeeperNode.runAction(startRight, completionHandler: {
        let moveSequence = SCNAction.sequence([moveLeft, moveRight])
        let moveLoop = SCNAction.repeatForever(moveSequence)
        goalkeeperNode.runAction(moveLoop)
      })
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
