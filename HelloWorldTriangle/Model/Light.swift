//
//  Light.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 29/09/2023.
//

import Foundation

class Light {
    
    var type: LightType
    var position: vector_float3?
    var eulers: vector_float3?
    var forwards: vector_float3?
    var color: vector_float3
    var t: Float?
    var rotationCenter: vector_float3?
    var pathRadius: Float?
    var pathPhi: Float?
    var angularVelocity: Float?
    
    init(color: vector_float3) {
        self.type = UNDEFINED
        self.color = color
    }
    
    func declareDirectional(eulers: vector_float3) {
        self.type = DIRECTOINAL
        self.eulers = eulers
    }
    
    func declareSpotlight(position: vector_float3, eulers: vector_float3) {
        self.type = SPOTLIGHT
        self.position = position
        self.eulers = eulers
        self.t = 0.0
    }
    
    func declarePointlight(rotationCenter: vector_float3, pathRadius: Float,
                           pathPhi: Float, angularVelocity: Float
    ) {
        self.type = POINTLIGHT
        self.rotationCenter = rotationCenter
        self.pathRadius = pathRadius
        self.pathPhi = pathPhi
        self.angularVelocity = angularVelocity
        self.t = 0.0
        self.position = rotationCenter
    }
    
    func update() {
        if type == DIRECTOINAL {
            forwards = [
                cos(eulers![2] * .pi / 180.0) * sin(eulers![1] * .pi / 180.0),
                sin(eulers![2] * .pi / 180.0) * sin(eulers![1] * .pi / 180.0),
                cos(eulers![1] * .pi / 180.0)
            ]
        } else if type == SPOTLIGHT {
            
            eulers![1] += 1
            if(eulers![1] > 360) {
                eulers![1] -= 360
            }
            
            forwards = [
                cos(eulers![2] * .pi / 180.0) * sin(eulers![1] * .pi / 180.0),
                sin(eulers![2] * .pi / 180.0) * sin(eulers![1] * .pi / 180.0),
                cos(eulers![1] * .pi / 180.0)
            ]
        } else if type == POINTLIGHT {
            
            position![0] = rotationCenter![0] + pathRadius! * cos(t!) * sin(pathPhi! * .pi / 180.0)
            position![1] = rotationCenter![1] + pathRadius! * sin(t!) * sin(pathPhi! * .pi / 180.0)
            position![2] = rotationCenter![2] + pathRadius! * cos(pathPhi! * .pi / 180.0)
           
            t! += angularVelocity! * 0.1;
            if t! > (2.0 * .pi) {
                t! -= 2.0 * .pi
            }
        }
    }
    
}
