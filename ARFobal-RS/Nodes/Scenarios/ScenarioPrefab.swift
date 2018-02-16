//
//  ScenarioPrefab.swift
//  ARFobal-RS
//
//  Created by Ignacio Ambrois on 2/2/18.
//  Copyright © 2018 Rootstrap. All rights reserved.
//

import Foundation
import SceneKit

class ScenarioPrefab {
  var ball: Ball!
  var ballInitialPosition: SCNVector3!
  
  func setup(scenarioNode: SCNNode, goalScale: Float) {
    preconditionFailure("This method must be overriden")
  }  
}
