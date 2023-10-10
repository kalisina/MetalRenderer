//
//  Extensions.swift
//  MetalRenderer
//
//  Created by Triumph on 10/10/2023.
//

import Foundation
import MetalKit

extension MTLVertexDescriptor {
    static func defaultVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0 // 0 from the beginning of the buffer
        vertexDescriptor.attributes[0].bufferIndex = 0 // position bufferIndex
        
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride // because we are using a single vertexBuffer
        vertexDescriptor.attributes[1].bufferIndex = 0 // color is now interleaved with position
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        return vertexDescriptor
    }
}
