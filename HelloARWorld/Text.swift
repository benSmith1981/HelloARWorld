//
//  Text.swift
//  HelloARWorld
//
//  Created by ben on 28/10/2017.
//  Copyright © 2017 ben. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class Text {
    var sceneView: ARSCNView!
    var textToDisplay: String
    var camCoords: MyCameraCoordinates
    init(sceneView: ARSCNView, textToDisplay: String, camCoords: MyCameraCoordinates) {
        self.textToDisplay = textToDisplay
        self.sceneView = sceneView
        self.camCoords = camCoords
    }
    
    func showHelloWorld() {
        let textGeometry = SCNText(string: "Hello, World!", extrusionDepth: 1.0)
        //        textGeometry.font = UIFont(name: "Arial", size: 2)
        //        textGeometry.firstMaterial!.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.01,0.01,0.01)
        //        center(node: textNode)
        let cc = camCoords.getCameraCoordinates(sceneView: sceneView)
        textNode.position = SCNVector3(cc.x, cc.y, cc.z)//SCNVector3(0, 0, -0.5)
        let pointOfView = sceneView.pointOfView
        textNode.simdPosition = pointOfView!.simdPosition + (pointOfView?.simdWorldFront)! * 2
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func showTextBillBoard(_ sender: Any) {
        let textGeometry = SCNText(string: "Hello, World!", extrusionDepth: 1.0)
        textGeometry.font = UIFont(name: "Arial", size: 2)
        textGeometry.firstMaterial!.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: textGeometry)
        
        center(node: textNode)
        
        let cc = camCoords.getCameraCoordinates(sceneView: sceneView)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        let plane = SCNPlane(width: 0.2, height: 0.2)
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor.blue
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
    
}
