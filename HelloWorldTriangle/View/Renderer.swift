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
    var meshAllocator: MTKMeshBufferAllocator
    var materialLoader: MTKTextureLoader
    
    let litPipleline: MTLRenderPipelineState
    let unlitPipleline: MTLRenderPipelineState
    
    let depthStencilState: MTLDepthStencilState
    
    let scene: GameScene
    
    let cubeMesh: OBJMesh
    let groundMesh: OBJMesh
    let catMesh: OBJMesh
    let lightMesh: OBJMesh
    
    let rockMaterial: Material
    let dirtMaterial: Material
    let catMaterial: Material
    let lightMaterial: Material
    
    init(_ parent: ContentView, scene: GameScene) {
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        self.meshAllocator = MTKMeshBufferAllocator(device: metalDevice)
        self.materialLoader = MTKTextureLoader(device: metalDevice)
        
        cubeMesh = OBJMesh(device: metalDevice, allocator: meshAllocator, fileName: "cube")
        rockMaterial = Material(device: metalDevice, allocator: materialLoader, fileName: "cubeTexture", filenameExtension: "jpg")
        
        groundMesh = OBJMesh(device: metalDevice, allocator: meshAllocator, fileName: "ground")
        dirtMaterial = Material(device: metalDevice, allocator: materialLoader, fileName: "dirt", filenameExtension: "jpg")
        
        catMesh = OBJMesh(device: metalDevice, allocator: meshAllocator, fileName: "cat")
        catMaterial = Material(device: metalDevice, allocator: materialLoader, fileName: "cat", filenameExtension: "png")
        
        lightMesh = OBJMesh(device: metalDevice, allocator: meshAllocator, fileName: "light")
        lightMaterial = Material(device: metalDevice, allocator: materialLoader, fileName: "light", filenameExtension: "png")
        
        guard let library: MTLLibrary = metalDevice.makeDefaultLibrary() else {
            fatalError()
        }
        let vertexDescriptor: MDLVertexDescriptor = cubeMesh.modelIOMesh.vertexDescriptor
        litPipleline = PipelineBuilder.BuildPipeline(metalDevice: metalDevice, library: library, vsEntry: "vertexShader", fsEntry: "fragmentShader", vertexDescriptor: vertexDescriptor)
        unlitPipleline = PipelineBuilder.BuildPipeline(metalDevice: metalDevice, library: library, vsEntry: "vertexShaderUnlit", fsEntry: "fragmentShaderUnlit", vertexDescriptor: vertexDescriptor)
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = metalDevice.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        
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
        
        drawLitObjects(renderEncoder: renderEncoder)
        
        drawUnlitObjects(renderEncoder: renderEncoder)
        
        renderEncoder?.endEncoding()
    
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func drawLitObjects(renderEncoder: MTLRenderCommandEncoder?) {
        renderEncoder?.setRenderPipelineState(litPipleline)
        renderEncoder?.setDepthStencilState(depthStencilState)
        
        sendCameraData(renderEncoder: renderEncoder)
        
        sendLightData(renderEncoder: renderEncoder)
        
        
        // Cube
        prepareForRendering(renderEncoder: renderEncoder, mesh: cubeMesh, material: rockMaterial)
        for cube in scene.cubes {
            draw(renderEncoder: renderEncoder, mesh: cubeMesh, modelTransform: &(cube.model!))
        }

        // Ground
        prepareForRendering(renderEncoder: renderEncoder, mesh: groundMesh, material: dirtMaterial)
        for ground in scene.groundTiles {
            draw(renderEncoder: renderEncoder, mesh: groundMesh, modelTransform: &(ground.model!))
        }
        
        prepareForRendering(renderEncoder: renderEncoder, mesh: catMesh, material: catMaterial)
        draw(renderEncoder: renderEncoder, mesh: catMesh, modelTransform: &(scene.cat.model))
    }
    
    func drawUnlitObjects(renderEncoder: MTLRenderCommandEncoder?) {
        renderEncoder?.setRenderPipelineState(unlitPipleline)
        renderEncoder?.setDepthStencilState(depthStencilState)
        
        sendCameraData(renderEncoder: renderEncoder)
        
        prepareForRendering(renderEncoder: renderEncoder, mesh: lightMesh, material: lightMaterial)
        for light in scene.pointLights {
            renderEncoder?.setFragmentBytes(&(light.color), length: MemoryLayout<simd_float3>.stride, index: 0)
            draw(renderEncoder: renderEncoder, mesh: lightMesh, modelTransform: &(light.model))
        }
        
      
    }
    
    func sendCameraData(renderEncoder: MTLRenderCommandEncoder?) {
        var cameraData: CameraParameters = CameraParameters()
        cameraData.view = scene.player.view!
        cameraData.projection = Matrix44.create_perspective_projection(
            fovy: 45, aspect: 800/600, near: 0.1, far: 20
        )
        renderEncoder?.setVertexBytes(&cameraData, length: MemoryLayout<CameraParameters>.stride, index: 2)
    }
    
    func sendLightData(renderEncoder: MTLRenderCommandEncoder?) {
        // Sun
        var sun: DirectionalLight = DirectionalLight()
        sun.forwards = scene.sun.forwards!
        sun.color = scene.sun.color
        renderEncoder?.setFragmentBytes(&sun, length: MemoryLayout<DirectionalLight>.stride, index: 0)
        
        // Spotlight
        var spotlight: Spotlight = Spotlight()
        spotlight.forwards = scene.spotLight.forwards!
        spotlight.color = scene.spotLight.color
        spotlight.position = scene.spotLight.position!
        renderEncoder?.setFragmentBytes(&spotlight, length: MemoryLayout<Spotlight>.stride, index: 1)
        
        // Pointlights
        var pointLights: [Pointlight] = []
        for light in scene.pointLights {
            pointLights.append(Pointlight(position: light.position, color: light.color))
        }
        renderEncoder?.setFragmentBytes(&pointLights, length: MemoryLayout<Pointlight>.stride, index: 2)
        
        var fragUBO: FragmentData = FragmentData()
        fragUBO.lightCount = UInt32(scene.pointLights.count)
        renderEncoder?.setFragmentBytes(&fragUBO, length: MemoryLayout<FragmentData>.stride * scene.pointLights.count, index: 3)
    }
    
    func prepareForRendering(renderEncoder: MTLRenderCommandEncoder?, mesh: OBJMesh, material: Material) {
        renderEncoder?.setVertexBuffer(mesh.metalMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        renderEncoder?.setFragmentTexture(material.texture, index: 0)
        renderEncoder?.setFragmentSamplerState(material.sampler, index: 0)
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder?, mesh: OBJMesh, modelTransform: UnsafeMutablePointer<matrix_float4x4>) {
        renderEncoder?.setVertexBytes(modelTransform, length: MemoryLayout<matrix_float4x4>.stride, index: 1)
        
        for submesh in mesh.metalMesh.submeshes {
            renderEncoder?.drawIndexedPrimitives(
                type: .triangle, indexCount: submesh.indexCount,
                indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset
            )
        }
    }
    
}
