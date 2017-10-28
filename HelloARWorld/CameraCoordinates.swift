//
//  CameraCoordinates.swift
//  HelloARWorld
//
//  Created by ben on 29/10/2017.
//  Copyright © 2017 ben. All rights reserved.
//

import Foundation

struct myCameraCoordinates {
    var x = Float()
    var y = Float()
    var z = Float()
    
    static func getCameraCoordinates(sceneView: ARSCNView) -> myCameraCoordinates {
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraCoordinates = MDLTransform(matrix: cameraTransform!)
        
        var cc = myCameraCoordinates()
        cc.x = cameraCoordinates.translation.x
        cc.y = cameraCoordinates.translation.y
        cc.z = cameraCoordinates.translation.z
        
        return cc
    }
}
