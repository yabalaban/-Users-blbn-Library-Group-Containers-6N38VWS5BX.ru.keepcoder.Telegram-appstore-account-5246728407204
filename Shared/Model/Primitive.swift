//
//  Primitive.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

struct Primitive {
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let indexCount: Int
    
    init(vertices: [SIMD3<Float>], indices: [UInt16], device: MTLDevice = Hardware.shared.device) {
        self.indexCount = indices.count
        var vertices = vertices
        guard let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<SIMD3<Float>>.stride * vertices.count, options: []) else {
            fatalError("Unable to create vertex buffer")
        }
        self.vertexBuffer = vertexBuffer
        var indices = indices
        guard let indexBuffer = device.makeBuffer(bytes: &indices, length: MemoryLayout<UInt16>.stride * indices.count, options: []) else {
            fatalError("Unable to create quad index buffer")
        }
        self.indexBuffer = indexBuffer
    }
}
