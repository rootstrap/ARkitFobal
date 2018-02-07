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
  var node: SCNNode!
  
  func setup(scenarioNode: SCNNode) {
    preconditionFailure("This method must be overriden")
  }
}

