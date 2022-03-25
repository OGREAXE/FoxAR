//
//  GameViewController.swift
//  SceneKitTest
//
//  Created by 梁志远 on 2022/3/16.
//

import UIKit
import QuartzCore
import SceneKit
import ARKit


class GameViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
    
    var gameController:GameController!
    
    var gameView:ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // retrieve the SCNView
        gameView = self.view as! ARSCNView
        
        gameController = GameController(scnView: gameView)

        // Configure the view
        gameView.backgroundColor = UIColor.black
        
        // Set the view's delegate
        gameView.delegate = self
        
        // Show statistics such as fps and timing information
        gameView.showsStatistics = true
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupARSession()
    }
    
    var arSession:ARSession? {
        get {
//            return nil
            return gameView.session
        }
    }
    
    func setupARSession() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        arSession?.run(configuration)
        
        arSession?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arSession?.pause()
    }
    
    /**
     Implement this to provide a custom node for the given anchor.
     
     @discussion This node will automatically be added to the scene graph.
     If this method is not implemented, a node will be automatically created.
     If nil is returned the anchor will be ignored.
     @param renderer The renderer that will render the scene.
     @param anchor The added anchor.
     @return Node that will be mapped to the anchor or nil.
     */
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//
//    }

    
    /**
     Called when a new node has been mapped to the given anchor.
     
     @param renderer The renderer that will render the scene.
     @param node The node that maps to the anchor.
     @param anchor The added anchor.
     */
    
    var hasInitedPostion = false
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !hasInitedPostion && node != gameView.scene.rootNode {
            hasInitedPostion = true
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            let  position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
            
            print("renderer didAdd node at \(position)")
            
//            gameView.scene.rootNode.position = position
        }
    }

    
    /**
     Called when a node will be updated with data from the given anchor.
     
     @param renderer The renderer that will render the scene.
     @param node The node that will be updated.
     @param anchor The anchor that was updated.
     */
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }

    
    /**
     Called when a node has been updated with data from the given anchor.
     
     @param renderer The renderer that will render the scene.
     @param node The node that was updated.
     @param anchor The anchor that was updated.
     */
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }

    
    /**
     Called when a mapped node has been removed from the scene graph for the given anchor.
     
     @param renderer The renderer that will render the scene.
     @param node The node that was removed.
     @param anchor The anchor that was removed.
     */
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
    }

    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        gameController.renderer(gameView, updateAtTime: time)
    }
}
