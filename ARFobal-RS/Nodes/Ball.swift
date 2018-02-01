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
    
  var state: BallState = BallState.NOT_PLACED
    
  init(goalScale: Float) {
    super.init()
    
    let ballScene = SCNScene(named: "art.scnassets/soccer-ball/ball.dae")

    guard let node = ballScene?.rootNode.childNode(withName: "ball", recursively: true) else {
        return
    }

    //IA: on very small scales the ball keeps rolling on top of the field when a force is applied to it, increasing the scale seems to have solved the problem
    let scale = max(0.00125, goalScale * 0.4)
    node.scale = SCNVector3(scale, scale, scale)
    print("ball scale: " + String(describing: scale))
    ballNode = node
    
    setup()
  }
  
  private func setup() {
    let sphere = SCNSphere(radius: CGFloat(38.68 * 0.5 * ballNode!.scale.x))
    let body = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: SCNPhysicsShape(geometry: sphere, options: nil))
    body.isAffectedByGravity = true
    body.mass = 0.5
    body.restitution = 0.5
    body.damping = 0.9
    body.angularDamping = 0.999
    body.friction = 0.8
    body.rollingFriction = 0.8
    body.categoryBitMask = BodyType.ball.rawValue
    self.ballNode!.physicsBody = body
    self.addChildNode(self.ballNode!)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
