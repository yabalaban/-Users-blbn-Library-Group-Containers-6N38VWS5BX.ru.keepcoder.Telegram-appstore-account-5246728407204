//
//  ForegroundPrimitive.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

struct ForegroundPrimitive {
    let primitive: Primitive
    
    init(device: MTLDevice) {
        let vertices = [
            SIMD3<Float>(-1.0, -1.0, 0.0),
            SIMD3<Float>(-1.0, +1.0, 0.0),
            SIMD3<Float>(+1.0, +1.0, 0.0),
            SIMD3<Float>(+1.0, -1.0, 0.0),
        ]
        let indices: [UInt16] = [
            0, 1, 2,
            0, 2, 3
        ]
        self.primitive = Primitive(vertices: vertices, indices: indices, device: device)
    }
}
