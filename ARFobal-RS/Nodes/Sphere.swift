//
//  Ball.swift
//  ARFobal-RS
//
//  Created by Pablo Malvasio on 9/15/17.
//  Copyright © 2017 Rootstrap. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Sphere: SCNNode {
  
  var ballNode: SCNNode?
  private var zVelocityOffset = 0.1
  
  init(goalScale: Float) {
    super.init()
    
    let sphere = SCNSphere(radius: CGFloat(goalScale*12/*5.069*/))
    sphere.firstMaterial?.diffuse.contents = UIColor.green
    self.ballNode = SCNNode(geometry: sphere)
    setupPhysicsBody()
  }
  
  func setupPhysicsBody() {
    let body = SCNPhysicsBody(type: .dynamic,
                              shape: nil)
    body.mass = 0.44
    body.angularDamping = 0.75
    body.restitution = 0.75
    body.damping = 1
    body.friction = 0.8
    body.categoryBitMask = BodyType.ball.rawValue
    ballNode!.physicsBody = body
    addChildNode(ballNode!)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

