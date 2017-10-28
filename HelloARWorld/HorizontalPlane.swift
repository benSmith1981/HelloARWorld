//
//  HorizontalPlane.swift
//  ARApp3
//
//  Created by Michal Kowalski on 17.07.2017.
//  Copyright © 2017 PGS Software. All rights reserved.
//

import SceneKit
import ARKit

final class HorizontalPlane: SCNNode {

    let planeGeometry: SCNPlane
    let material = SCNMaterial()
    let anchor: ARPlaneAnchor

    init(anchor: ARPlaneAnchor) {
        planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let hC = Double(arc4random() % 255)
        let sC = Double(arc4random() % 255)
        let bC = Double(arc4random() % 255)
        material.diffuse.contents = UIColor(hue: CGFloat(1.0 / 255.0 * hC), saturation: CGFloat(1.0 / 255.0 * sC), brightness: CGFloat(1.0 / 255.0 * bC), alpha: 1.0)
        self.anchor = anchor
        super.init()
        material.isDoubleSided = true
        planeGeometry.firstMaterial = material
        geometry = planeGeometry
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1.0, 0.0, 0.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    func update(for anchor: ARPlaneAnchor) {
        planeGeometry.height = CGFloat(anchor.extent.z)
        planeGeometry.width = CGFloat(anchor.extent.x)
        geometry = planeGeometry
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
    
    func createLavaPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
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
    

}
