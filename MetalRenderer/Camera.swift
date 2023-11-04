//
//  Camera.swift
//  MetalRenderer
//
//  Created by Triumph on 04/11/2023.
//

import Foundation
import MetalKit

class Camera {
    var transform = Transform()
    
    var viewMatix: float4x4 {
        let translateMatrix = float4x4(translation: transform.position)
        let rotateMatrix = float4x4(rotation: transform.rotation)
        let scaleMatrix = float4x4(scaling: transform.scale)
        return (translateMatrix * scaleMatrix * rotateMatrix).inverse
    }
    
    var fov = radians(fromDegrees: 60)
    var near: Float = 0.1
    var far: Float = 100
    var aspect: Float = 1
    
    var projectionMaxtrix: float4x4 {
        return float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
    }
    
    func zoom(delta: Float) {}
    func rotate(delta: SIMD2<Float>) {}
}

class ArcballCamera: Camera {
    var minDistance = 0.5
    var maxDistance = 10
    var distance: Float = 0 {
        didSet {
            _viewMatrix = updateViewMatrix()
        }
    }
    var target = SIMD3<Float>(repeating: 0) {
        didSet {
            _viewMatrix = updateViewMatrix()
        }
    }
    
    override var viewMatix: float4x4 {
        return _viewMatrix
    }
    
    private var _viewMatrix = float4x4.identity
    
    override init() {
        super.init()
        _viewMatrix = updateViewMatrix()
    }
    
    private func updateViewMatrix() -> float4x4 {
        let translationMatrix = float4x4(translation: [target.x, target.y, target.z - distance])
        let rotateMatrix = float4x4(rotationYXZ: [ -transform.rotation.x,
                                                    transform.rotation.y,
                                                    0])
        let matrix = (rotateMatrix * translationMatrix).inverse
        transform.position = rotateMatrix.upperLeft * -matrix.columns.3.xyz
        return matrix
    }
    
    override func zoom(delta: Float) {
        let sensitivity: Float = 0.05
        distance -= delta * sensitivity
        _viewMatrix = updateViewMatrix()
    }
    
    override func rotate(delta: SIMD2<Float>) {
        let sensitivity: Float = 0.005
        transform.rotation.y += delta.x * sensitivity
        transform.rotation.x += delta.y * sensitivity
        transform.rotation.x = max(-Float.pi/2, min(transform.rotation.x, Float.pi/2))
        _viewMatrix = updateViewMatrix()
    }
}
