//
//  Renderer.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 28/09/2023.
//

import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    var parent: ContentView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    var allocator: MTKMeshBufferAllocator
    var materialLoader: MTKTextureLoader
    let pipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    
    let scene: GameScene
    
    let cubeMesh: OBJMesh
    let groundMesh: OBJMesh
    
    let rockMaterial: Material
    let dirtMaterial: Material
    
    init(_ parent: ContentView, scene: GameScene) {
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        self.allocator = MTKMeshBufferAllocator(device: metalDevice)
        self.materialLoader = MTKTextureLoader(device: metalDevice)
        
        cubeMesh = OBJMesh(device: metalDevice, allocator: allocator, fileName: "cube")
        rockMaterial = Material(device: metalDevice, allocator: materialLoader, fileName: "cubeTexture")
        
        groundMesh = OBJMesh(device: metalDevice, allocator: allocator, fileName: "ground")
        dirtMaterial = Material(device: metalDevice, allocator: materialLoader, fileName: "dirt")
        
        let pipeDescriptor = MTLRenderPipelineDescriptor()
        let library = metalDevice.makeDefaultLibrary()
        pipeDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipeDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipeDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(cubeMesh.metalMesh.vertexDescriptor)
        pipeDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = metalDevice.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipeDescriptor)
        }catch {
            fatalError()
        }
        
        self.scene = scene
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        scene.update()
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1);
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setDepthStencilState(depthStencilState)
        
        var cameraData: CameraParameters = CameraParameters()
        cameraData.view = scene.player.view!
        cameraData.projection = Matrix44.create_perspective_projection(
            fovy: 45,
            aspect: 800/600,
            near: 0.1,
            far: 20
        )
        renderEncoder?.setVertexBytes(&cameraData, length: MemoryLayout<CameraParameters>.stride, index: 2)
        
        // Cube
        renderEncoder?.setVertexBuffer(
            cubeMesh.metalMesh.vertexBuffers[0].buffer,
            offset: 0,
            index: 0
        )
        
        renderEncoder?.setFragmentTexture(rockMaterial.texture, index: 0)
        renderEncoder?.setFragmentSamplerState(rockMaterial.sampler, index: 0)
        for cube in scene.cubes {
            
            renderEncoder?.setVertexBytes(&(cube.model!), length: MemoryLayout<matrix_float4x4>.stride, index: 1)
            
            for submesh in cubeMesh.metalMesh.submeshes {
                renderEncoder?.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer.buffer,
                    indexBufferOffset: submesh.indexBuffer.offset
                )
            }
        }
        
        // Ground
        renderEncoder?.setVertexBuffer(
            groundMesh.metalMesh.vertexBuffers[0].buffer,
            offset: 0,
            index: 0
        )
        
        renderEncoder?.setFragmentTexture(dirtMaterial.texture, index: 0)
        renderEncoder?.setFragmentSamplerState(dirtMaterial.sampler, index: 0)
        for ground in scene.groundTiles {
            
            renderEncoder?.setVertexBytes(&(ground.model!), length: MemoryLayout<matrix_float4x4>.stride, index: 1)
            
            for submesh in groundMesh.metalMesh.submeshes {
                renderEncoder?.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer.buffer,
                    indexBufferOffset: submesh.indexBuffer.offset
                )
            }
        }
        
        renderEncoder?.endEncoding()
    
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    
}
