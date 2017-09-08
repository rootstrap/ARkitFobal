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
  init(position: SCNVector3, sceneView: ARSCNView) {
    super.init()
    
    if let scene = SCNScene(named: "art.scnassets/soccer-goal/goal-2.dae"),
        let node = scene.rootNode.childNode(withName: "goal-2", recursively: true) {
      node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
      node.position = position
//      node.transform = SCNMatrix4MakeRotation(Float(-.pi / 2.0), 0.0, 1.0, 0.0)
      node.scale = SCNVector3(0.002, 0.002, 0.002)
      sceneView.scene.rootNode.addChildNode(node)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
