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
  var planeGeometry: SCNPlane!
  
  init(anchor: ARPlaneAnchor) {
    
    anchorPoint = anchor
    super.init()
    setup()
  }
  
  private func setup() {
    planeGeometry = SCNPlane(width: CGFloat(anchorPoint.extent.x), height: CGFloat(anchorPoint.extent.z))
    
    let material = SCNMaterial()
    material.diffuse.contents = UIImage(named:"grass-2")
    
    //Repeat texture pattern
    material.diffuse.wrapS = SCNWrapMode.repeat
    material.diffuse.wrapT = SCNWrapMode.repeat
    material.diffuse.contentsTransform = SCNMatrix4MakeScale(6, 6, 0)
    
    planeGeometry.materials = [material]
    
    let planeNode = SCNNode(geometry: planeGeometry)
    planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: [:]))
    planeNode.physicsBody?.categoryBitMask = BodyType.plane.rawValue
    //planeNode.physicsBody?.collisionBitMask = BodyType.ball.rawValue
    planeNode.position = SCNVector3Make(anchorPoint.center.x, 0, anchorPoint.center.z)
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
    
    // add to the parent
    addChildNode(planeNode)
  }
  
  func update(anchor: ARPlaneAnchor) {
    
    planeGeometry.width = CGFloat(anchor.extent.x)
    planeGeometry.height = CGFloat(anchor.extent.z)
    position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    
    if let planeNode = childNodes.first {
      planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
