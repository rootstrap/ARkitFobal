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
    
    let camProjection = SCNVector3(sceneView.pointOfView!.position.x, hitResult.worldTransform.columns.3.y, sceneView.pointOfView!.position.z)
    let currentPlace = SCNNode()
    currentPlace.position = camProjection
    
    if let scene = SCNScene(named: "art.scnassets/soccer-goal/goal.dae"),
        let node = scene.rootNode.childNode(withName: "goal", recursively: true) {
      node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
      node.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
      
      let distance = hitResult.distance
      node.scale = SCNVector3(distance*0.002, distance*0.002, distance*0.002)
      node.constraints = [SCNLookAtConstraint(target: currentPlace)]
      
      node.physicsBody?.categoryBitMask = BodyType.goal.rawValue
      self.addChildNode(node)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
