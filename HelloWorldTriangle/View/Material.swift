//
//  Material.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 28/09/2023.
//

import Foundation
import MetalKit

class Material {
    
    let texture: MTLTexture
    let sampler: MTLSamplerState
    
    init(device: MTLDevice, allocator: MTKTextureLoader, fileName: String) {
        guard let materialURL = Bundle.main.url(forResource: fileName, withExtension: "jpg") else {
            fatalError()
        }
        
        let options: [MTKTextureLoader.Option : Any] = [
            .SRGB: false
        ]
        
        do {
            texture = try allocator.newTexture(URL: materialURL, options: options)
        } catch {
            fatalError()
        }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .linear
        
        sampler = device.makeSamplerState(descriptor: samplerDescriptor)!
    }
}
