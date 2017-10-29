//
//  AddShapes.swift
//  HelloARWorld
//
//  Created by ben on 28/10/2017.
//  Copyright © 2017 ben. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class Shapes {
    var cubeNode:SCNNode!
    
    init() {
        addCube()
    }
    
    func addCube() {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
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
        cubeNode = SCNNode(geometry: box)
        //        let cc = myCameraCoordinates.getCameraCoordinates(sceneView: sceneView)
        cubeNode.position = SCNVector3(0,0,-2)
    }
}
