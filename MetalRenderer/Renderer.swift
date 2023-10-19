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
        /*
        let vertexLength = MemoryLayout<Vertex>.stride * vertices.count
        self.vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexLength)!
        
        let indexLength = MemoryLayout<UInt16>.stride * indexArray.count
        self.indexBuffer = device.makeBuffer(bytes: indexArray, length: indexLength)!
         */
        
        train = Model(name: "train")
        
        super.init()
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
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

extension Renderer: MTKViewDelegate {
    // called when window is resized or if phone is rotating
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
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
        
        //commandEncoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
        //commandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        
        for mtkMesh in train.mtkMeshes {
            for vertexBuffer in mtkMesh.vertexBuffers {
                commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
                
                for submesh in mtkMesh.submeshes {
                    // draw call
                    commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
                }
                
            }
        }
        
       
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
