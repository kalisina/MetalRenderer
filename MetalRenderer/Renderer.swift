//
//  Renderer.swift
//  MetalRenderer
//
//  Created by Triumph on 02/10/2023.
//

import Foundation
import MetalKit

struct Vertex {
    let position: SIMD3<Float>
    let color: SIMD3<Float>
}

class Renderer: NSObject {
    static var device: MTLDevice! // needs to be initialized only once
    let commandQueue: MTLCommandQueue // needs to be initialized only once
    static var library: MTLLibrary! // needs to be initialized only once
    let pipelineState: MTLRenderPipelineState // needs to be initialized only once
    let depthStencilState: MTLDepthStencilState
    
    /*
    let vertices: [Vertex] = [
      Vertex(position:  SIMD3<Float>(-0.5, -0.2, 0), color:  SIMD3<Float>(1, 0, 0)),
      Vertex(position:  SIMD3<Float>(0.2, -0.2, 0), color:  SIMD3<Float>(0, 1, 0)),
      Vertex(position:  SIMD3<Float>(0, 0.5, 0), color:  SIMD3<Float>(0, 0, 1)),
      Vertex(position:  SIMD3<Float>(0.7, 0.7, 0), color:  SIMD3<Float>(1, 0, 1))
    ]
    
    let indexArray: [uint16] = [
        0, 1, 2,
        2, 1, 3
    ]
    
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
     */
    
    let train: Model
    let tree: Model
    let camera = ArcballCamera()
    
    var uniforms = Uniforms()
    
    var timer: Float = 0
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()!
        self.pipelineState = Renderer.createPipelineState()
        self.depthStencilState = Renderer.createDepthState()
        
        view.depthStencilPixelFormat = .depth32Float // necessary to create the texture (depth) on the metal view
        /*
        let vertexLength = MemoryLayout<Vertex>.stride * vertices.count
        self.vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexLength)!
        
        let indexLength = MemoryLayout<UInt16>.stride * indexArray.count
        self.indexBuffer = device.makeBuffer(bytes: indexArray, length: indexLength)!
         */
        
        train = Model(name: "train")
        train.transform.position = [0.4, 0.0, 0.0]
        //train.transform.rotation.z = radians(fromDegrees: 45.0)
        train.transform.scale = 0.5
        
        tree = Model(name: "treefir")
        tree.transform.position = [-1.0, 0.0, 0.5]
        tree.transform.scale = 0.5
        
        //camera.transform.position = [0, 0.5, -3]
        camera.target = [0, 0.8, 0]
        camera.distance = 3
        
        super.init()
    }
    
    static func createDepthState() -> MTLDepthStencilState {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less // pixels closer to the camera with the smaller depth will be visible
        depthDescriptor.isDepthWriteEnabled = true // allow writting new values to the depth texture
        return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
    }
    
    static func createPipelineState() -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        // pipeline state properties
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm //metalView uses bgra8Unorm
        let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
        let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float // must use the same pixel format as the depthStencilPixelFormat of the Metal View
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

extension Renderer: MTKViewDelegate {
    // called when window is resized or if phone is rotating
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(view.bounds.width / view.bounds.height)
    }
    
    // called every frame
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(), // will be created every frame
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        timer += 0.5
        //var currentTime: Float = sin(timer)
        //commandEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 2)
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setDepthStencilState(depthStencilState)
        
        //commandEncoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
        //commandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        
        uniforms.viewMatrix = camera.viewMatix
        uniforms.projectionMatrix = camera.projectionMaxtrix
        /*
        let projectionMatrix = float4x4(projectionFov: radians(fromDegrees: 65), near: 0.1, far: 100, aspect: Float(view.bounds.width / view.bounds.height))
        
        var viewTransform = Transform()
        viewTransform.position.y = 1.0;
        viewTransform.position.z = -2.0;
        
        var viewMatrix = projectionMatrix * viewTransform.matrix.inverse
        commandEncoder.setVertexBytes(&viewMatrix, length: MemoryLayout<float4x4>.stride, index: 22)
         */
        
        let models = [tree, train]
        
        for model in models {
            
            uniforms.modelMatrix = model.transform.matrix
            commandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 21) //using high index number to keep it separate from the other indices we've used
            
            var color: Int = 0
            
            for mtkMesh in model.mtkMeshes {
                for vertexBuffer in mtkMesh.vertexBuffers {
                    commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
                    
                    for submesh in mtkMesh.submeshes {
                        
                        commandEncoder.setVertexBytes(&color, length: MemoryLayout<Int>.stride, index: 11) // we can use setVertexBytes because the data is less than 4kb, otherwise, we would need to use a buffer
                        
                        // draw call
                        commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
                        
                        color += 1
                    }
                    
                }
            }
        }
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
