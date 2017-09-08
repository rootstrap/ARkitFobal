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
  @IBOutlet var detectButton: UIButton!
  
  var detectionActivated = true
  var plane: Field?
  var goal: Goal?
  
  //MARK; Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    registerGestureRecognizers()
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
    togglePlaneDetection()
  }
  
  func togglePlaneDetection() {
    let configuration = ARWorldTrackingConfiguration()
    var debugOptions: SCNDebugOptions = []
    
    if detectionActivated {
      //Delete all nodes
      sceneView.scene.rootNode.enumerateChildNodes { (node, _) -> Void in
        node.removeFromParentNode()
      }
      
      configuration.planeDetection = .horizontal
      debugOptions = [ARSCNDebugOptions.showFeaturePoints]
      detectionActivated = !detectionActivated
    }
    
    sceneView.session.run(configuration)
    sceneView.debugOptions = debugOptions
  }
  
  //MARK: Actions
  @IBAction func toggleDetection() {
    detectionActivated = !detectionActivated
    togglePlaneDetection()
  }
  
  func registerGestureRecognizers() {
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
    self.sceneView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc func tapped(recognizer: UIGestureRecognizer) {
    let vector = SCNVector3((plane?.anchorPoint.center.x)!,
                            (plane?.anchorPoint.center.y)!,
                            (plane?.anchorPoint.center.z)!)
    
    goal = Goal(position: vector, sceneView: sceneView)
    togglePlaneDetection()
  }
}

extension GameController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
    //Check if the detection is a new anchor for planes
    guard anchor is ARPlaneAnchor else { return }
    
    //Plane detected
    DispatchQueue.main.async {
      self.detectButton.isUserInteractionEnabled = !self.detectionActivated
    }
    
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
