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
  init(hitResult: ARHitTestResult, sceneView: ARSCNView) {
    super.init()
    
    if let scene = SCNScene(named: "art.scnassets/soccer-goal/goal-3.dae"),
        let node = scene.rootNode.childNode(withName: "goal-3", recursively: true) {
      node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
      node.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
      let distance = hitResult.distance
      node.scale = SCNVector3(distance*0.002, distance*0.002, distance*0.002)
      sceneView.scene.rootNode.addChildNode(node)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
