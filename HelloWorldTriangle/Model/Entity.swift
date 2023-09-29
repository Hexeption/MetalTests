//
//  Entity.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 29/09/2023.
//

import Foundation

class Entity {
    
    var hasTransformComponent: Bool
    var position: simd_float3?
    var eulers: simd_float3?
    var model: matrix_float4x4?
    
    var hasCameraComponent: Bool
    var forwards: vector_float3?
    var right: vector_float3?
    var up: vector_float3?
    var view: matrix_float4x4?
    
    init() {
        self.hasTransformComponent = false
        self.hasCameraComponent = false
    }
    
    func addTransformComponent(position: simd_float3, eulers: simd_float3) {
        self.hasTransformComponent = true
        self.position = position
        self.eulers = eulers
        update()
    }
    
    func addCameraComponent(position: simd_float3, eulers: simd_float3) {
        self.hasCameraComponent = true
        self.position = position
        self.eulers = eulers
        update()
    }
    
    func strafe(rightAmmount: Float, upAmmount: Float) {
        position = position! + rightAmmount * right! + upAmmount * up!
        
        let distance: Float = simd.length(position!)
        moveForwards(ammount: distance - 10.0)
    }
    
    func moveForwards(ammount: Float) {
        position = position! + ammount * forwards!
    }
    
    func update() {
        
        if hasTransformComponent {
            model = Matrix44.create_from_rotation(eulers: eulers!)
            model = Matrix44.create_from_translation(translation: position!) * model!
        }
        
        if hasCameraComponent {
            forwards = simd.normalize([0,0,0] - position!)
            
            let globalUp: vector_float3 = [0.0, 0.0, 1.0]
            
            right = simd.normalize(simd.cross(globalUp, forwards!))
            
            up = simd.normalize(simd.cross(forwards!, right!))
            
            view = Matrix44.create_lookat(
                eye: position!,
                target: [0,0,0],
                up: up!
            )
            
        }
    }
}
