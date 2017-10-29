//
//  ViewController.swift
//  HelloARWorld
//
//  Created by ben on 17/10/2017.
//  Copyright © 2017 ben. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

protocol SceneViewController {
    func addNodeToSceneView(node:SCNNode,at position: SCNVector3)
    func addNodeToPointOfView(node:SCNNode)
    func addNodeAtCameraPosition(node:SCNNode)
    func placeNodeInfrontOfCamera(node:SCNNode) 
}

class ViewController: UIViewController, ARSCNViewDelegate, SceneViewController {

    @IBOutlet var sceneView: ARSCNView!
    var camCoords: MyCameraCoordinates = MyCameraCoordinates()
    var zombie: Zombie!
    var earth: Earth!
    var text: Text!
    var shape: Shapes!
 
    // AR Planes
    var planeDetected = false
    var planes: [ARAnchor: HorizontalPlane] = [:]
    var selectedPlane: HorizontalPlane?
    
    enum ViewState {
        case searchPlanes
        case selectPlane
        case startGame
        case playing
    }
    
    var state: ViewState = .searchPlanes {
        didSet {
            //            updateHintView()
            if state == .playing {
                planes.values.forEach { plane in
                    plane.isHidden = true
                }
            } else {
                planes.values.forEach { plane in
                    plane.isHidden = true
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSceneViewObjects()
        setupTapGestures()
        setupSwipeGestures()
    }
    
    func createSceneViewObjects() {
        earth = Earth.init()
        earth.delegate = self

        text = Text.init(textToDisplay: "Hello World!")
        zombie = Zombie.init()
        shape = Shapes.init()
    }
    
    func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeft.direction = .left
        sceneView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeRight.direction = .right
        sceneView.addGestureRecognizer(swipeRight)
    }
    
    func setupTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    func configureSceneView() {
        // Set the view's delegate
        sceneView.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    func showArStatistics() {
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

//MARK: Zombie Animations
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)

        // Let's test if a 3D Object was touch
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true

        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)

        if hitResults.first != nil {
            if(zombie.idle) {
                zombie.idle = false
                zombie.transition = true
                playAnimation(key: "transition")
            } else if(zombie.transition) {
                zombie.idle = false
                zombie.transition = false
                zombie.walking = true
                playAnimation(key: "walking")
            } else {
                stopAnimation(key: "walking")
            }
//            zombie.idle = !zombie.idle
            return
        }
    }
    
    func playAnimation(key: String) {
        // Add the animation to start playing it right away
//        let sequence = SCNAction.sequence(zombie.animations[key]!) // will be executed one by one
//        let node = SCNNode()
//        node.runAction(sequence, completionHandler:nil)
        
        sceneView.scene.rootNode.addAnimation(zombie.animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(1))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

//MARK: AR Plane Detection
    // When a plane is detected, make a planeNode for it
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard state == .searchPlanes || state == .selectPlane else {
            return
        }
        
        if let anchor = anchor as? ARPlaneAnchor {
            if state == .searchPlanes {
                state = .selectPlane
            }
            let horizontalPlane = HorizontalPlane(anchor: anchor)
            planes[anchor] = horizontalPlane
            node.addChildNode(horizontalPlane)
        }
    }

    // When a detected plane is updated, make a new planeNode
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor,
            let plane = planes[anchor] {
            plane.update(for: anchor)
            if selectedPlane?.anchor == anchor {
//                gameController.updateGameSceneForAnchor(anchor: anchor)
            }
        }
    }

    // When a detected plane is removed, remove the planeNode
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            if plane == self.selectedPlane {
                let nextPlane = planes.values.first!
//                zombie.addToNode(rootNode: nextPlane)
//                gameController.updateGameSceneForAnchor(anchor: nextPlane.anchor)
            }
            plane.removeFromParentNode()
        }
    }

    @IBAction func showWorldOrSphere(_ sender: Any) {
        addNodeToPointOfView(node: earth.spotLightNode)
        placeNodeInfrontOfCamera(node: earth.worldWrapperNode)
    }
    
//MARK: Tap and Swipe gestures
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if hitResults.count > 0 {
            if let result = hitResults.first,
                let selectedPlane = result.node as? HorizontalPlane {
                self.selectedPlane = selectedPlane
                let planeNode = selectedPlane.createLavaPlaneNode(anchor: selectedPlane.anchor)
                state = .startGame
                zombie.addToNode(rootNode: selectedPlane.parent!)
//                gameController.updateGameSceneForAnchor(anchor: selectedPlane.anchor)
            }
        }
    }
    
    @objc func swipeRight(_ swipeGestureRecognize: UISwipeGestureRecognizer) {
        earth.rotateNode(node: earth.worldWrapperNode, direction: 2)
    }

    @objc func swipeLeft(_ swipeGestureRecognize: UISwipeGestureRecognizer) {
        earth.rotateNode(node: earth.worldWrapperNode, direction: -2)
    }
    
    @IBAction func helloWorld(_ sender: Any) {
        placeNodeInfrontOfCamera(node: text.helloWorldNode)
    }
    
    @IBAction func addCube(_ sender: Any) {
        placeNodeInfrontOfCamera(node: shape.cubeNode)
    }
    
    @IBAction func adBillboard(_ sender: Any) {
        placeNodeInfrontOfCamera(node: text.billBoardNode)
    }
    
//MARK: Scene View Session interrupted delegates

    func resetARSession() {
        // Called by sessionInterruptionDidEnd
        
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode() }
        configureSceneView()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("session didFailWithError")

    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("sessionWasInterrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        resetARSession()
    }

//MARK: Delegate functions to add nodes to view
    func addNodeToSceneView(node:SCNNode,at position: SCNVector3){
        node.position = position
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    func addNodeToPointOfView(node:SCNNode){
        self.sceneView.pointOfView?.addChildNode(node)
    }
    
    func addNodeAtCameraPosition(node:SCNNode){
        let cc = camCoords.getCameraCoordinates(sceneView: sceneView)
        node.position = SCNVector3(cc.x, cc.y, cc.z)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    func placeNodeInfrontOfCamera(node:SCNNode) {
        let pointOfView = self.sceneView.pointOfView
        node.simdPosition = pointOfView!.simdPosition + (pointOfView?.simdWorldFront)! * 2
        self.sceneView.scene.rootNode.addChildNode(node)
    }
}