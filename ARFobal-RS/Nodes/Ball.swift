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

class Ball: SCNNode {
  init(hitResult: ARHitTestResult, sceneView: ARSCNView, goalScale: Float) {
    super.init()
    
    if let scene = SCNScene(named: "art.scnassets/soccer-ball/ball.dae"),
      let node = scene.rootNode.childNode(withName: "JABULANI", recursively: true) {
      
      node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
      node.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                 hitResult.worldTransform.columns.3.y,
                                 hitResult.worldTransform.columns.3.z)

      node.scale = SCNVector3(goalScale*0.0265, goalScale*0.0265, goalScale*0.0265)
      node.physicsBody?.categoryBitMask = BodyType.ball.rawValue
      self.addChildNode(node)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
