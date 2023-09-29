//
//  Billboard.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 29/09/2023.
//

import Foundation

class Billboard {

    var position: simd_float3
    var model: matrix_float4x4
    
    init(position: simd_float3) {
        self.position = position
        self.model = Matrix44.create_identity()
    }
    
    func update(viewerPosition: simd_float3) {
        
        let selfToViwer: simd_float3 = viewerPosition - position
        let theta: Float = simd.atan2(selfToViwer[1], selfToViwer[0]) * 180.0 / .pi
        let horizontalDistance: Float = sqrtf(selfToViwer[0] * selfToViwer[0] + selfToViwer[1] * selfToViwer[1])
        let phi: Float = -simd.atan2(selfToViwer[2], horizontalDistance) * 180.0 / .pi
        
        model = Matrix44.create_from_rotation(eulers: [0, phi, theta])
        model = Matrix44.create_from_translation(translation: position) * model
    }
}
