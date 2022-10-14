//
//  GameOfLifeScene.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

enum GameOfLifePattern {
    case pixel
    case glider
    case pulsar
    case hwss
    case gliderGun
}

struct GameOfLifeScene {
    private unowned let view: MTKView
    private let hardware: Hardware
    private let foreground: ForegroundPrimitive
    private var grid: GridPrimitive
    private var gridState: GridState
    private var params: Params
    private var cachedSize: (width: Int, height: Int) = (1, 1)
    private lazy var foregroundPSO: MTLRenderPipelineState = makeForegroundPSO()
    private lazy var gridPSO: MTLRenderPipelineState = makeGridPSO()
    
    init(view: MTKView, hardware: Hardware) {
        self.view = view
        self.hardware = hardware
        foreground = ForegroundPrimitive(device: hardware.device)
        grid = GridPrimitive(width: cachedSize.width, height: cachedSize.height, device: hardware.device)
        gridState = GridState()
        gridState.update(width: cachedSize.width, height: cachedSize.height)
        params = Params(width: Float(view.frame.size.width),
                        height: Float(view.frame.size.height),
                        gridWidth: Int32(cachedSize.width),
                        gridHeight: Int32(cachedSize.height))
    }
}

// MARK: - GridScene
extension GameOfLifeScene: GridScene {
    mutating func tick() {
        gridState.next()
    }
    
    mutating func spawn(pattern: GameOfLifePattern, at location: (x: Float, y: Float)) {
        let xStep = Float(view.frame.size.width) / Float(cachedSize.width)
        let x = Int(location.x / xStep)
        let yStep = Float(view.frame.size.height) / Float(cachedSize.height)
        let y = cachedSize.height - Int(location.y / yStep) - 1
        switch pattern {
        case .pixel:
            gridState.spawnPixel(x: x, y: y)
        case .glider:
            gridState.spawnGlider(x: x, y: y)
        case .pulsar:
            gridState.spawnPulsar(x: x, y: y)
        case .hwss:
            gridState.spawnHWSS(x: x, y: y)
        case .gliderGun:
            gridState.spawnGliderGun(x: x, y: y)
        }
    }
    
    mutating func update(width: Int, height: Int) -> Bool {
        guard (width: width, height: height) != cachedSize else { return false }
        cachedSize = (width: width, height: height)
        gridState.update(width: width, height: height)
        grid = GridPrimitive(width: width, height: height, device: hardware.device)
        params = Params(width: Float(view.frame.size.width),
                        height: Float(view.frame.size.height),
                        gridWidth: Int32(width),
                        gridHeight: Int32(height))
        return true
    }
    
    mutating func clear() {
        gridState.update(width: cachedSize.width, height: cachedSize.height)
    }
    
    mutating func render(encoder: MTLRenderCommandEncoder) {
        // Foreground
        encoder.setFragmentBytes(&params,
                                 length: MemoryLayout<Params>.stride,
                                 index: 0)
        // TODO: use buffer
        encoder.setFragmentBytes(gridState.cells,
                                 length: MemoryLayout<Bool>.stride * gridState.cells.count,
                                 index: 1)
        encoder.setRenderPipelineState(foregroundPSO)
        encoder.setVertexBuffer(foreground.primitive.vertexBuffer,
                                offset: 0,
                                index: 0)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: foreground.primitive.indexCount,
                                      indexType: .uint16,
                                      indexBuffer: foreground.primitive.indexBuffer,
                                      indexBufferOffset: 0)
        // Grid
        encoder.setRenderPipelineState(gridPSO)
        encoder.setVertexBuffer(grid.primitive.vertexBuffer,
                                offset: 0,
                                index: 0)
        encoder.drawIndexedPrimitives(type: .line,
                                      indexCount: grid.primitive.indexCount,
                                      indexType: .uint16,
                                      indexBuffer: grid.primitive.indexBuffer,
                                      indexBufferOffset: 0)
    }
}

// MARK: - PSO
extension GameOfLifeScene {
    private func makeForegroundPSO() -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = hardware.library.makeFunction(name: "vertex_main_foreground")
        pipelineDescriptor.fragmentFunction = hardware.library.makeFunction(name: "fragment_main_foreground")
        pipelineDescriptor.vertexDescriptor = .defaultLayout
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        do {
            return try hardware.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    private func makeGridPSO() -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = hardware.library.makeFunction(name: "vertex_main_grid")
        pipelineDescriptor.fragmentFunction = hardware.library.makeFunction(name: "fragment_main_grid")
        pipelineDescriptor.vertexDescriptor = .defaultLayout
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        do {
            return try hardware.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
