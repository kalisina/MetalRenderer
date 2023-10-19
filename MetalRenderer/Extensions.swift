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
        
        /*
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride // because we are using a single vertexBuffer
        vertexDescriptor.attributes[1].bufferIndex = 0 // color is now interleaved with position
         */ // not needed when importing model from Model IO
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
        return vertexDescriptor
    }
}

extension MDLVertexDescriptor {
    // returns a Model IO Vertex Descriptor created from the Metal Vertex Descriptor
    static func defaultVertexDescriptor() -> MDLVertexDescriptor {
        let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(.defaultVertexDescriptor())
        
        let attributePosition = vertexDescriptor.attributes[0] as! MDLVertexAttribute // attributes[0] is used for the vertex position data (the color will come in through materiel settings and not by each vertex)
        attributePosition.name = MDLVertexAttributePosition
        
        return vertexDescriptor
    }
}
