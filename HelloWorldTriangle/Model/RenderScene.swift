//
//  RenderScene.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 28/09/2023.
//

import Foundation

class RenderScene {
    
    var player: Camera
    var triangles: [SimpleComponent]
    
    init() {
        player = Camera(
            position: [0, 0, 0],
            eulers: [0, 90, 0]
        )
        
        triangles = [
            SimpleComponent(
                position: [5, 0, 0],
                eulers: [0, 0, 0]
            )
        ]
    }
    
    func update() {
        player.updateVectors()
        
        for triangle in triangles {
            triangle.eulers.z += 1
            if triangle.eulers.z > 360 {
                triangle.eulers.z -= 360
            }
        }
    }
}
