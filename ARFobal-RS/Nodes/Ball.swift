//
//  Ball.swift
//  ARFobal-RS
//
//  Created by Pablo Malvasio on 9/15/17.
//  Copyright © 2017 Rootstrap. All rights reserved.
//

import Foundation
import SceneKit

class Ball: SCNNode {
  
  var ballNode: SCNNode?
  
  private var zVelocityOffset = 0.1
  
  init(goalScale: Float) {
    super.init()
    
    let ballScene = SCNScene(named: "art.scnassets/soccer-ball/ball.dae")
     
     guard let node = ballScene?.rootNode.childNode(withName: "ball", recursively: true) else {
     return
     }

    //node.scale = SCNVector3(goalScale, goalScale, goalScale)
    
    node.scale = SCNVector3(goalScale*0.265, goalScale*0.265, goalScale*0.265)
    ballNode = node
    
    /*let sphere = SCNSphere(radius: 0.02)
    sphere.firstMaterial?.diffuse.contents = UIColor.green
    self.ballNode = SCNNode(geometry: sphere)*/
    
    setup()
  }
  
  private func setup() {
    
    let sphere = SCNSphere(radius: CGFloat(38.68*0.5*(ballNode?.scale.x)!))
    let sphereShape = SCNPhysicsShape(geometry: sphere)
    let body = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: sphereShape)
    sphere.firstMaterial?.diffuse.contents = UIColor.green
    //self.ballNode = SCNNode(geometry: sphere)
    body.isAffectedByGravity = true
    body.mass = 0.5
    body.restitution = 0.5
    body.damping = 0.9
    body.angularDamping = 0.82
    body.friction = 0.8
    body.categoryBitMask = BodyType.ball.rawValue
    body.contactTestBitMask = BodyType.goal.rawValue
   // body.collisionBitMask = BodyType.goal.rawValue | BodyType.plane.rawValue
    self.ballNode!.physicsBody = body
    self.addChildNode(self.ballNode!)
    /*self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
     self.physicsBody?.isAffectedByGravity = true*/
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
