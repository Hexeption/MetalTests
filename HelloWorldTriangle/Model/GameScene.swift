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
    @Published var sun: Light
    @Published var spotLight: Light
    @Published var cubes: [Entity]
    @Published var groundTiles: [Entity]
    @Published var pointLights: [BrightBillboard]
    @Published var cat: Billboard
    
    init() {
        
        cubes = []
        groundTiles = []
        pointLights = []
        
        let newPlayer = Entity()
        newPlayer.addCameraComponent(position: [-6, 6, 4], eulers: [0, 110, -45])
        player = newPlayer
        
        let newCat = Billboard(position: [0.0, 0.0, 3])
        cat = newCat
        
        let newSpotLight = Light(color: [1.0, 0.0, 0.0])
        newSpotLight.declareSpotlight(position: [-2, 0.0, 2.0], eulers: [0, 0.0, 180])
        spotLight = newSpotLight
        
        let newSun = Light(color: [0.7, 0.7, 0.7])
        newSun.declareDirectional(eulers: [0, 135, 45])
        sun = newSun
        sun.update()
        
        let newCube = Entity()
        newCube.addTransformComponent(position: [0.0, 0.0, 1.0], eulers: [0.0, 0.0, 0.0])
        cubes.append(newCube)
        
        let newTile = Entity()
        newTile.addTransformComponent(position: [0.0, 0.0, 0.0], eulers: [90.0, 0.0, 0.0])
        groundTiles.append(newTile)
        
        var newPointLight = BrightBillboard(position: [0.0, 0.0, 1.0], color: [0.0, 1.0, 1.0], rotation_center: [0.0, 0.0, 1.0], pathRadius: 2.0, pathPhi: 60.0, angularVelocity: 1.0)
        pointLights.append(newPointLight)
        newPointLight = BrightBillboard(position: [0.0, 0.0, 1.0], color: [0.0, 0.0, 1.0], rotation_center: [0.0, 0.0, 1.0], pathRadius: 3.0, pathPhi: 0.0, angularVelocity: 2.0)
        pointLights.append(newPointLight)
    }
    
    func updateView() {
        self.objectWillChange.send()
    }
    
    func update() {
        player.update()
        
        for cube in cubes {
            cube.update()
        }
        
        for groundTile in groundTiles {
            groundTile.update()
        }
        
        spotLight.update()
        
        for pointLight in pointLights {
            pointLight.update(viewerPosition: player.position!)
        }
        
        cat.update(viewerPosition: player.position!)
        
        updateView()
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
    
    func strafePlayer(offset: CGSize) {
        let rightAmmount: Float = Float(offset.width) / 1000
        let upAmmount: Float = Float(offset.height) / 1000
          
        player.strafe(rightAmmount: rightAmmount, upAmmount: upAmmount)
    }
}
