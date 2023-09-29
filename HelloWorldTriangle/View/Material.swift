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
    
    init(device: MTLDevice, allocator: MTKTextureLoader, fileName: String, filenameExtension: String) {
   
        let options: [MTKTextureLoader.Option : Any] = [
            .SRGB: false,
            .generateMipmaps: true
        ]
        
        guard let materialURL = Bundle.main.url(forResource: fileName, withExtension: filenameExtension) else {
            fatalError()
        }
        
        do {
            texture = try allocator.newTexture(URL: materialURL, options: options)
        } catch {
            fatalError("couldn't load material from \(fileName)")
        }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.maxAnisotropy = 8
        
        sampler = device.makeSamplerState(descriptor: samplerDescriptor)!
    }
}
