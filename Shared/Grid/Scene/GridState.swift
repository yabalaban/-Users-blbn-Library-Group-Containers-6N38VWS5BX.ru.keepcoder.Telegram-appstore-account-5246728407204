//
//  GridState.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

struct GridState {
    private(set) lazy var current: MTLBuffer = {
        makeBuffer()
    }()
    private(set) lazy var next: MTLBuffer = {
        makeBuffer()
    }()
    private var count: Int
    private unowned let device: MTLDevice
    
    init(count: Int, device: MTLDevice = Hardware.shared.device) {
        self.count = count
        self.device = device
    }
    
    mutating func update(count: Int) {
        self.count = count
        current = makeBuffer()
        next = makeBuffer()
    }
    
    private mutating func makeBuffer() -> MTLBuffer {
        var cells = [Bool].init(repeating: false, count: count)
        guard let buffer = device.makeBuffer(bytes: &cells, length: MemoryLayout<Bool>.stride * cells.count, options: []) else {
            fatalError("Unable to create vertex buffer")
        }
        return buffer
    }
}
