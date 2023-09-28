//
//  OBJMesh.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 28/09/2023.
//

import MetalKit

class OBJMesh {
    
    let modelIOMesh: MDLMesh
    let metalMesh: MTKMesh
    
    init(device: MTLDevice, allocator: MTKMeshBufferAllocator, fileName: String) {
        guard let meshURL = Bundle.main.url(forResource: fileName, withExtension: "obj") else {
            fatalError()
        }
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        var offset: Int = 0
        
        // position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = offset
        vertexDescriptor.attributes[0].bufferIndex = 0
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        // texture
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = offset
        vertexDescriptor.attributes[1].bufferIndex = 0
        offset += MemoryLayout<SIMD2<Float>>.stride
        
        vertexDescriptor.layouts[0].stride = offset
        
        let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (meshDescriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        
        let asset = MDLAsset(
            url: meshURL,
            vertexDescriptor: meshDescriptor,
            bufferAllocator: allocator
        )
        
        modelIOMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        do {
            metalMesh = try MTKMesh(mesh: modelIOMesh, device: device)
        } catch {
            fatalError()
        }
            
        
    }
}
