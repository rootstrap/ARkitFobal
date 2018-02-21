//
//  Scenario1.swift
//  ARFobal-RS
//
//  Created by Ignacio Ambrois on 2/2/18.
//  Copyright © 2018 Rootstrap. All rights reserved.
//

import Foundation
import SceneKit

class Scenario1 : ScenarioPrefab {
  
  var dummyNode: SCNNode!
  var dummies: [SCNNode]!
  
  override func setup(scenarioNode: SCNNode, goalScale: Float) {
    if let scene = SCNScene(named: "art.scnassets/dummy/dummy.dae"){
      
      dummyNode = scene.rootNode.childNode(withName: "Dummy", recursively: true)
      dummies = []
      
      setDummy(scenarioNode: scenarioNode, position: SCNVector3(-25, 50, -280), scale: SCNVector3(10,10,10))
      setDummy(scenarioNode: scenarioNode, position: SCNVector3(25, 50, -280), scale: SCNVector3(10,10,10))
      
      ballInitialPosition = SCNVector3(0, 50, -380)
    }
  }
  
  func setDummy(scenarioNode: SCNNode, position: SCNVector3, scale: SCNVector3) {
    let dummy = dummyNode.clone()
    
    let eulerAngles = SCNVector3(0, GLKMathDegreesToRadians(90), 0)
    dummy.eulerAngles = eulerAngles
    
    scenarioNode.addChildNode(dummy)
    
    dummy.position = position
    dummy.scale = scale
    dummy.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
    
    dummies.append(dummy)
  }
  
  override func remove() {
    dummies.forEach { (dummy) in
      dummy.removeFromParentNode()
    }
  }
}
