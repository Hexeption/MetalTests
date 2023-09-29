//
//  PipelineBuilder.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 29/09/2023.
//

import Foundation
import MetalKit

class PipelineBuilder {
    
    static func BuildPipeline(metalDevice: MTLDevice, library: MTLLibrary, vsEntry: String, fsEntry: String, vertexDescriptor: MDLVertexDescriptor) -> MTLRenderPipelineState {
        let pipeDescriptor = MTLRenderPipelineDescriptor()
        let library = metalDevice.makeDefaultLibrary()
        pipeDescriptor.vertexFunction = library?.makeFunction(name: vsEntry)
        pipeDescriptor.fragmentFunction = library?.makeFunction(name: fsEntry)
        pipeDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipeDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipeDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipeDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipeDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipeDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipeDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipeDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        pipeDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            return try metalDevice.makeRenderPipelineState(descriptor: pipeDescriptor)
        }catch {
            fatalError()
        }
    }
    
}
