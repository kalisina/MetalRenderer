//
//  Transform.swift
//  MetalRenderer
//
//  Created by Triumph on 30/10/2023.
//

import Foundation
import simd

struct Transform {
    var position = SIMD3<Float>(0.0, 0.0, 0.0)
    var rotation = SIMD3<Float>(0.0, 0.0, 0.0)
    var scale: Float = 1
    
    var matrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotationMatrix = float4x4(rotation: rotation)
        let scaleMatrx = float4x4(scaling: scale)
        return translateMatrix * scaleMatrx * rotationMatrix // right to left multiplication
    }
}
