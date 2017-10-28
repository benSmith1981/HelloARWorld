//
//  World.swift
//  HelloARWorld
//
//  Created by ben on 28/10/2017.
//  Copyright © 2017 ben. All rights reserved.
//
import Foundation
import UIKit
import SceneKit
import ARKit

class Earth {
//    var sceneView: ARSCNView!
    var worldWrapperNode = SCNNode()
    var delegate: SceneViewController?
    let spotLightNode = SCNNode()

    init() {
        getSceneObject()
        setupLight()
    }
    
    func getSceneObject(){
        guard let virtualObjectScene = SCNScene(named: "art.scnassets/SimpleEarth/EarthPlanet.DAE") else {
            return
        }
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            worldWrapperNode.addChildNode(child)
        }
        worldWrapperNode.scale = SCNVector3(0.01, 0.01, 0.01)

    }
    
    func setupLight() {
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.spotInnerAngle = 60
        spotLight.spotOuterAngle = 60
        spotLight.intensity = 1
        spotLightNode.light = spotLight
    }
    
    func rotateNode(node:SCNNode, direction: CGFloat) {
        let rotateAction = SCNAction.rotate(by: CGFloat.pi * direction, around: SCNVector3(0, 1, 0), duration: 10.0)
        //        node.runAction(SCNAction.repeatForever(rotateAction))
        node.runAction(rotateAction)
        
    }
}
