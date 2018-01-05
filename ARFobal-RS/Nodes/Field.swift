//
//  Field.swift
//  ARFobal-RS
//
//  Created by Pablo Malvasio on 9/8/17.
//  Copyright © 2017 Rootstrap. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Field: SCNNode {
  
  var anchorPoint: ARPlaneAnchor
  var planeGeometry: SCNBox!
  
  init(anchor: ARPlaneAnchor) {
    
    anchorPoint = anchor
    super.init()
    setup()
  }
  
  private func setup() {
    //planeGeometry = SCNPlane(width: CGFloat(anchorPoint.extent.x), height: CGFloat(anchorPoint.extent.z))
    //IA: The ball appears to roll off the plane if the height of this box isn't at least 0.015, the same thing happens with a plane
    planeGeometry = SCNBox(width: CGFloat(anchorPoint.extent.x), height: 0.015, length: CGFloat(anchorPoint.extent.z), chamferRadius: 0)
    
    let material = SCNMaterial()
    material.diffuse.contents = UIImage(named:"grass-2")
    
    //Repeat texture pattern
    material.diffuse.wrapS = SCNWrapMode.repeat
    material.diffuse.wrapT = SCNWrapMode.repeat
    material.diffuse.contentsTransform = SCNMatrix4MakeScale(6, 6, 0)
    
    planeGeometry.materials = [material]
    
    let planeNode = SCNNode(geometry: planeGeometry)
    planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: [:]))
    planeNode.physicsBody?.restitution = 0.0
    planeNode.physicsBody?.friction = 1.0
    planeNode.physicsBody?.categoryBitMask = BodyType.plane.rawValue
    planeNode.physicsBody?.contactTestBitMask = BodyType.ball.rawValue | BodyType.plane.rawValue
    planeNode.position = SCNVector3Make(anchorPoint.center.x, 0, anchorPoint.center.z)
    planeNode.transform = SCNMatrix4MakeRotation(0.0, 1.0, 0.0, 0.0)
    
    
    
    // add to the parent
    addChildNode(planeNode)
  }
  
  func update(anchor: ARPlaneAnchor) {
    
    planeGeometry.width = CGFloat(anchor.extent.x)
    planeGeometry.length = CGFloat(anchor.extent.z)
    position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    
    if let planeNode = childNodes.first {
      planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
