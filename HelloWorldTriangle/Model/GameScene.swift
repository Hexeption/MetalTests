//
//  RenderScene.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 28/09/2023.
//

import Foundation
import SwiftUI

class GameScene: ObservableObject {
    
    @Published var player: Entity
    @Published var cubes: [Entity]
    @Published var groundTiles: [Entity]
    
    init() {
        
        cubes = []
        groundTiles = []
        
        let newPlayer = Entity()
        newPlayer.addCameraComponent(position: [-6, 6, 4], eulers: [0, 110, -45])
        player = newPlayer
        
        let newCube = Entity()
        newCube.addTransformComponent(position: [0.0, 0.0, 1.0], eulers: [0.0, 0.0, 0.0])
        cubes.append(newCube)
        
        let newTile = Entity()
        newTile.addTransformComponent(position: [0.0, 0.0, 0.0], eulers: [90.0, 0.0, 0.0])
        groundTiles.append(newTile)
    }
    
    func update() {
        player.update()
        
        for cube in cubes {
            cube.update()
        }
        
        for groundTile in groundTiles {
            groundTile.update()
        }
    }
    
    func spinPlayer(offset: CGSize) {
        let dTheta: Float = Float(offset.width)
        let dPhi: Float = Float(offset.height)
          
        player.eulers!.z -= 0.001 * dTheta
        player.eulers!.y += 0.001 * dPhi
          
        if player.eulers!.z < 0 {
            player.eulers!.z -= 360
        } else if player.eulers!.z > 360 {
            player.eulers!.z -= 360
        }
          
        if player.eulers!.y < 1 {
            player.eulers!.y = 1
        } else if player.eulers!.y > 179 {
            player.eulers!.y = 179
        }
    }
}
