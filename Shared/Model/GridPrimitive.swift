//
//  GridPrimitive.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

struct GridPrimitive {
    let primitive: Primitive
    
    init(width: Int, height: Int, device: MTLDevice) {
        var vertices = [SIMD3<Float>].init(repeating: SIMD3<Float>(), count: 2 * (width + height))
        var indices = [UInt16].init(repeating: 0, count: 2 * (width + height))
        populateX(vertices: &vertices, indices: &indices, count: width, step: 2.0 / Float(width))
        populateY(vertices: &vertices, indices: &indices, count: height, step: 2.0 / Float(height), starting: width)
        self.primitive = Primitive(vertices: vertices, indices: indices, device: device)
    }
}

private func populateX(vertices: inout [SIMD3<Float>], indices: inout [UInt16], count: Int, step: Float, starting: Int = 0) {
    var val: Float = -1.0
    for i in 0..<count {
        vertices[2 * (starting + i) + 0] = SIMD3<Float>(-1.0, val, 0.0)
        vertices[2 * (starting + i) + 1] = SIMD3<Float>(1.0, val, 0.0)
        indices[2 * (starting + i) + 0] = 2 * UInt16(starting + i)
        indices[2 * (starting + i) + 1] = 2 * UInt16(starting + i) + 1
        val += step
    }
}

private func populateY(vertices: inout [SIMD3<Float>], indices: inout [UInt16], count: Int, step: Float, starting: Int = 0) {
    var val: Float = -1.0
    for i in 0..<count {
        vertices[2 * (starting + i) + 0] = SIMD3<Float>(val, -1.0, 0.0)
        vertices[2 * (starting + i) + 1] = SIMD3<Float>(val, 1.0, 0.0)
        indices[2 * (starting + i) + 0] = 2 * UInt16(starting + i)
        indices[2 * (starting + i) + 1] = 2 * UInt16(starting + i) + 1
        val += step
    }
}
