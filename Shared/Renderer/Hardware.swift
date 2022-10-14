//
//  Hardware.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

final class Hardware {
    static let shared = Hardware()
    
    lazy var device: MTLDevice = {
        guard let device =  MTLCreateSystemDefaultDevice() else {
            fatalError("GPU is not supported")
        }
        return device
    }()
    lazy var commandQueue: MTLCommandQueue = {
        guard let queue = device.makeCommandQueue() else {
            fatalError("GPU is not supported")
        }
        return queue
    }()
    lazy var library: MTLLibrary = {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Default library is missing")
        }
        return library
    }()
}

