//
//  GameController.swift
//  ARFobal-RS
//
//  Created by Pablo Malvasio on 9/7/17.
//  Copyright © 2017 Rootstrap. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameController: UIViewController {
  
  @IBOutlet var sceneView: ARSCNView!
  var plane: Field?
  
  //MARK; Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setSceneConf()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    sceneView.session.pause()
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
    
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
  }
  
  //MARK: Setup
  func setSceneConf() {
    sceneView.delegate = self
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    
    //See yellow detection points
    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    sceneView.showsStatistics = true
    sceneView.session.run(configuration)
  }
  
  func stopPlaneDetection() {
    sceneView.session.run(ARWorldTrackingConfiguration())
    sceneView.debugOptions = []
  }
}

extension GameController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
    //Check if the detection is a new anchor for planes
    guard anchor is ARPlaneAnchor else { return }
    
    //Plane detected
    stopPlaneDetection()
    
    //Add field
    if let planeAnchor = anchor as? ARPlaneAnchor {
      plane = Field(anchor: planeAnchor)
      node.addChildNode(plane!)
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

    if let planeAnchor = anchor as? ARPlaneAnchor {
      plane?.update(anchor: planeAnchor)
    }
  }
}
