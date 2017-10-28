//
//  Zombie.swift
//  HelloARWorld
//
//  Created by ben on 28/10/2017.
//  Copyright © 2017 ben. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class Zombie {
    
    //this holds all the differnet types of animations
    var animations = [String: CAAnimation]()
    //Is the animation idle or not
    var idle:Bool = true
    
    init() {
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
        //        sceneView.scene.rootNode.addChildNode(node)
        
        // Load all the DAE animations
        loadAnimation(withKey: "idle", sceneName: "art.scnassets/ZombieIdle/ZombieIdle", animationIdentifier: "Zombie_Hips-anim")
        
        loadAnimation(withKey: "transition", sceneName: "art.scnassets/ZombieTransition/ZombieTransition", animationIdentifier: "Zombie_Hips-anim")
        
        loadAnimation(withKey: "walking", sceneName: "art.scnassets/Walking/Walking-1", animationIdentifier: "Walking-1-1")
        
    }
    
    func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
        
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
    
    func addStaticZombie(_ sender: Any) {
        guard let virtualObjectScene = SCNScene(named: "zombie.dae", inDirectory: "art.scnassets/zombie") else {
            return
        }

        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        wrapperNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
    }
}
