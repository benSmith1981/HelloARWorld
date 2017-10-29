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
    var textToDisplay: String
    var billBoardNode = SCNNode()
    var helloWorldNode = SCNNode()
    
    init(textToDisplay: String) {
        self.textToDisplay = textToDisplay
        setupHelloWorld()
        setupTextBillBoard()
    }
    
    func setupHelloWorld() {
        let textGeometry = SCNText(string: "Hello, World!", extrusionDepth: 1.0)
        //        textGeometry.font = UIFont(name: "Arial", size: 2)
        //        textGeometry.firstMaterial!.diffuse.contents = UIColor.red
        helloWorldNode = SCNNode(geometry: textGeometry)
        helloWorldNode.scale = SCNVector3(0.01,0.01,0.01)
        center(node: helloWorldNode)

    }
    
    func setupTextBillBoard() {
        let textGeometry = SCNText(string: "Hello, World!", extrusionDepth: 1.0)
        textGeometry.font = UIFont(name: "Arial", size: 2)
        textGeometry.firstMaterial!.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: textGeometry)
        
        center(node: textNode)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        let plane = SCNPlane(width: 0.2, height: 0.2)
        let blueMaterial = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor.blue
        plane.firstMaterial = blueMaterial
        billBoardNode = SCNNode(geometry: plane) // this node will hold our text node
        
        let yFreeConstraint = SCNBillboardConstraint()
        yFreeConstraint.freeAxes = .Y // optionally
        billBoardNode.constraints = [yFreeConstraint] // apply the constraint to the parent node
        billBoardNode.addChildNode(textNode)
        
    }
    
    func center(node: SCNNode) {
        let (min, max) = node.boundingBox
        
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        node.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
    }
    
}
