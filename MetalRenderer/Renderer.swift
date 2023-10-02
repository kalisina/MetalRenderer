//
//  Renderer.swift
//  MetalRenderer
//
//  Created by Triumph on 02/10/2023.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice! // needs to be initialized only once
    let commandQueue: MTLCommandQueue // needs to be initialized only once
    static var library: MTLLibrary! // needs to be initialized only once
    let pipelineState: MTLRenderPipelineState // needs to be initialized only once
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()!
        self.pipelineState = Renderer.createPipelineState()
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
        
        commandEncoder.setRenderPipelineState(pipelineState)
        // draw call
        commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 1)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}