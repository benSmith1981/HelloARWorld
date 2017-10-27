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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var zombieWalkingNode: SCNNode?
    var zombieBitingNode: SCNNode?
    var planeDetected = false

    var animations = [String: CAAnimation]()
    var idle:Bool = true
    
    struct myCameraCoordinates {
        var x = Float()
        var y = Float()
        var z = Float()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        loadAnimations()
    }
    
    func loadAnimations () {
        // Load the character in the idle animation
        let idleScene = SCNScene(named: "art.scnassets/ZombieIdle/ZombieIdle.dae")!
//        let idleScene = SCNScene(named: "art.scnassets/ZombieTransition/ZombieTransition.dae")!

        // This node will be parent of all the animation models
        let node = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        // Set up some properties
        node.position = SCNVector3(0, -1, -2)
        node.scale = SCNVector3(0.01, 0.01, 0.01)
        
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        
        // Load all the DAE animations
        loadAnimation(withKey: "idle", sceneName: "art.scnassets/ZombieIdle/ZombieIdle", animationIdentifier: "Zombie_Hips-anim")

        loadAnimation(withKey: "transition", sceneName: "art.scnassets/ZombieTransition/ZombieTransition", animationIdentifier: "Zombie_Hips-anim")

    }
    
    func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {

        // Load the character from one of our dae documents, for instance "idle.dae"
//        let idleURL = Bundle.main.url(forResource: sceneName, withExtension: "dae");
//        let idleScene = try! SCNScene(url: idleURL!, options: nil);
//        // Merge the loaded scene into our main scene in order to
//        //   place the character in our own scene
//        for child in idleScene.rootNode.childNodes {
//            sceneView.scene.rootNode.addChildNode(child)
//        }
//        loadAnimation(animation: .Attack, sceneName: sceneName, animationIdentifier: "mixamorig_Hips-anim");

        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            // The animation will only play once
            animationObject.repeatCount = 1
            animationObject.autoreverses = true
            // To create smooth transitions between animations
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(1)
            
            // Store the animation for later use
            animations[withKey] = animationObject
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        // Let's test if a 3D Object was touch
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
        
        if hitResults.first != nil {
            if(idle) {
                playAnimation(key: "transition")
            } else {
                stopAnimation(key: "transition")
            }
            idle = !idle
            return
        }
    }
    
    func playAnimation(key: String) {
        // Add the animation to start playing it right away
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)

    }
    
    func stopAnimation(key: String) {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(1))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // When a plane is detected, make a planeNode for it
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//        let plane = createPlaneNode(anchor: planeAnchor)
//        node.addChildNode(plane)
//    }
//
//    // When a detected plane is updated, make a new planeNode
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//
//        // Remove existing plane nodes
//        node.enumerateChildNodes {
//            (childNode, _) in
//            childNode.removeFromParentNode()
//        }
//
//
//        let planeNode = createPlaneNode(anchor: planeAnchor)
//
//        node.addChildNode(planeNode)
//    }
//
//    // When a detected plane is removed, remove the planeNode
//    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        guard anchor is ARPlaneAnchor else { return }
//
//        // Remove existing plane nodes
//        node.enumerateChildNodes {
//            (childNode, _) in
//            childNode.removeFromParentNode()
//        }
//    }
    
    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        // Create a SceneKit plane to visualize the node using its position and extent.
        // Create the geometry and its materials
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let lavaImage = #imageLiteral(resourceName: "lava")
        let lavaMaterial = SCNMaterial()
        lavaMaterial.diffuse.contents = lavaImage
        lavaMaterial.isDoubleSided = true
        
        plane.materials = [lavaMaterial]
        
        // Create a node with the plane geometry we created
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        // SCNPlanes are vertically oriented in their local coordinate space.
        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        return planeNode
    }
    
    @IBAction func helloWorld(_ sender: Any) {
        showHelloWorld()

    }
    
    @IBAction func addZombie(_ sender: Any) {
        
//        let zombieNode = SCNNode()
//        center(node: zombieNode)

        guard let virtualObjectScene = SCNScene(named: "zombie.dae", inDirectory: "art.scnassets/zombie") else {
            return
        }
        
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        let pointOfView = sceneView.pointOfView
        let cc = getCameraCoordinates(sceneView: sceneView)
        wrapperNode.scale = SCNVector3(0.01, 0.01, 0.01)
        wrapperNode.position = SCNVector3(cc.x, cc.y, cc.z)
        wrapperNode.simdPosition = pointOfView!.simdPosition + (pointOfView?.simdWorldFront)! * 0.5
//        let yFreeConstraint = SCNBillboardConstraint()
//        yFreeConstraint.freeAxes = .Y // optionally
//        wrapperNode.constraints = [yFreeConstraint]
//        zombieNode.addChildNode(wrapperNode)
        sceneView.scene.rootNode.addChildNode(wrapperNode)

    }
    
    func getCameraCoordinates(sceneView: ARSCNView) -> myCameraCoordinates {
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraCoordinates = MDLTransform(matrix: cameraTransform!)
        
        var cc = myCameraCoordinates()
        cc.x = cameraCoordinates.translation.x
        cc.y = cameraCoordinates.translation.y
        cc.z = cameraCoordinates.translation.z
        
        return cc
    }
    
    func showHelloWorld() {
        let textGeometry = SCNText(string: "Hello, World!", extrusionDepth: 1.0)
//        textGeometry.font = UIFont(name: "Arial", size: 2)
//        textGeometry.firstMaterial!.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.01,0.01,0.01)
//        center(node: textNode)
        let cc = self.getCameraCoordinates(sceneView: sceneView)
        textNode.position = SCNVector3(cc.x, cc.y, cc.z)//SCNVector3(0, 0, -0.5)
        let pointOfView = sceneView.pointOfView
        textNode.simdPosition = pointOfView!.simdPosition + (pointOfView?.simdWorldFront)! * 2
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    @IBAction func addText(_ sender: Any) {
        let textGeometry = SCNText(string: "Hello, World!", extrusionDepth: 1.0)
        textGeometry.font = UIFont(name: "Arial", size: 2)
        textGeometry.firstMaterial!.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: textGeometry)

        center(node: textNode)
        
        let cc = self.getCameraCoordinates(sceneView: sceneView)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        let plane = SCNPlane(width: 0.2, height: 0.2)
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor.clear
        plane.firstMaterial = blueMaterial
        let parentNode = SCNNode(geometry: plane) // this node will hold our text node
        
        let yFreeConstraint = SCNBillboardConstraint()
        yFreeConstraint.freeAxes = .Y // optionally
        parentNode.constraints = [yFreeConstraint] // apply the constraint to the parent node
        
        parentNode.position = SCNVector3(cc.x, cc.y, cc.z)//SCNVector3(0, 0, -0.5)
        parentNode.addChildNode(textNode)
        
        sceneView.scene.rootNode.addChildNode(parentNode)
    }
    
    func center(node: SCNNode) {
        let (min, max) = node.boundingBox
        
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        node.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
    }
    
    @IBAction func addCube(_ sender: Any) {
        var box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let colors = [UIColor.green, // front
            UIColor.red, // right
            UIColor.blue, // back
            UIColor.yellow, // left
            UIColor.purple, // top
            UIColor.gray] // bottom
        
        let sideMaterials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }

        
        box.materials = sideMaterials
        let cubeNode = SCNNode(geometry: box)
        let cc = self.getCameraCoordinates(sceneView: sceneView)
        cubeNode.position = SCNVector3(0,0,-2)
        sceneView.scene.rootNode.addChildNode(cubeNode)
    }
    

    var planes: [ARAnchor: HorizontalPlane] = [:]
    var selectedPlane: HorizontalPlane?
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if hitResults.count > 0 {
            if let result = hitResults.first,
                let selectedPlane = result.node as? HorizontalPlane {
                self.selectedPlane = selectedPlane
                let planeNode = self.createPlaneNode(anchor: selectedPlane.anchor)
                sceneView.scene.rootNode.addChildNode(planeNode)
//                state = .startGame
//                gameController.addToNode(rootNode: selectedPlane.parent!)
//                gameController.updateGameSceneForAnchor(anchor: selectedPlane.anchor)
            }
        }
    }
}
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        for result in sceneView.hitTest(touch.location(in: sceneView), types: [.existingPlaneUsingExtent, .featurePoint]) {
//            print(result.distance, result.worldTransform)
//            if let anchorPlane = result.anchor as? ARPlaneAnchor {
//                let planeNode = self.createPlaneNode(anchor: anchorPlane)
//                sceneView.scene.rootNode.addChildNode(planeNode)
//            }
//
//
//        }
    
//        let hits = self.sceneView.hitTest(touch.location(in: sceneView), options: nil)
//        if let tappedNode = hits?.first?.node {
//
//        }
////        let results = sceneView.hitTest(touch.location(in: sceneView),  options: [:])
//        let planeHitTestResults = sceneView.hitTest(touch.location(in: sceneView), types: .existingPlaneUsingExtent)
//        if let result = planeHitTestResults.first {
//
//            let planeHitTestPosition = SCNVector3.init(result.worldTransform)
//            let planeAnchor = result.anchor
//
//            // Return immediately - this is the best possible outcome.
////            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
//            self.createPlaneNode(anchor: result.anchor as! ARPlaneAnchor)
//
//        }
//
//        let planeHitTestResults = sceneView.hitTest(touch.location(in: sceneView), types: .existingPlaneUsingExtent)
//        if let result = planeHitTestResults.first, let planeHitTestPosition = SCNVector3.in (result.) {
////        if let result = results.first,
//
//            let planeAnchor = result.anchor
//
//            self.selectedPlane = selectedPlane
//            if let anchor = self.selectedPlane?.anchor {
//                self.createPlaneNode(anchor: anchor)
//            }
////            addToNode(rootNode: selectedPlane.parent!)
//        }
        

//    public var worldSceneNode: SCNNode?
//
//    func addToNode(rootNode: SCNNode) {
//        guard let worldScene = worldSceneNode else {
//            return
//        }
//        worldScene.removeFromParentNode()
//        rootNode.addChildNode(worldScene)
//        worldScene.scale = SCNVector3(0.1, 0.1, 0.1)
//    }




    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    


