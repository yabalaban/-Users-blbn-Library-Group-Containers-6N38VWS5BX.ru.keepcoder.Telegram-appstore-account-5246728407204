//
//  GameOfLifeScene.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

struct GameOfLifeScene {
    private unowned let view: MTKView
    private let hardware: Hardware
    private let foreground: ForegroundPrimitive
    private var grid: GridPrimitive
    private var gridState: GridState
    private var params: Params
    private var uniforms: Uniforms = Uniforms()
    private var cachedSize: (width: Int, height: Int) = (1, 1)
    private var spawnQueue: [Pattern] = []
    
    private lazy var foregroundPSO: MTLRenderPipelineState = makeForegroundPSO()
    private lazy var gridPSO: MTLRenderPipelineState = makeGridPSO()
    private lazy var computeTickPSO: MTLComputePipelineState = makeComputeTickPSO()
    private lazy var computeCopyPSO: MTLComputePipelineState = makeComputeCopyPSO()
    private lazy var computeSpawnPSO: MTLComputePipelineState = makeComputeSpawnPSO()
    
    init(view: MTKView, hardware: Hardware) {
        self.view = view
        self.hardware = hardware
        foreground = ForegroundPrimitive(device: hardware.device)
        grid = GridPrimitive(width: cachedSize.width, height: cachedSize.height, device: hardware.device)
        gridState = GridState(count: cachedSize.width * cachedSize.height)
        params = Params(width: Float(view.frame.size.width),
                        height: Float(view.frame.size.height),
                        gridWidth: Int32(cachedSize.width),
                        gridHeight: Int32(cachedSize.height))
    }
}

// MARK: - GridScene
extension GameOfLifeScene: GridScene {
    mutating func tick(encoder: MTLComputeCommandEncoder) {
        if spawnQueue.count > 0 {
            spawnPatterns(encoder: encoder)
        } else {
            calculateNextState(encoder: encoder)
        }
    }
    
    mutating func spawn(model: PatternModel, at location: (x: Float, y: Float)) {
        let xStep = Float(view.frame.size.width) / Float(cachedSize.width)
        let x = UInt32(location.x / xStep)
        let yStep = Float(view.frame.size.height) / Float(cachedSize.height)
        let y = UInt32(cachedSize.height - Int(location.y / yStep) - 1)
        let origin = (x: x, y: y)
        spawnQueue.append(Pattern(origin: origin, model: model))
    }
    
    mutating func update(width: Int, height: Int) -> Bool {
        guard (width: width, height: height) != cachedSize else { return false }
        cachedSize = (width: width, height: height)
        gridState.update(count: width * height)
        grid = GridPrimitive(width: width, height: height, device: hardware.device)
        params = Params(width: Float(view.frame.size.width),
                        height: Float(view.frame.size.height),
                        gridWidth: Int32(width),
                        gridHeight: Int32(height))
        return true
    }
    
    mutating func clear() {
        gridState.update(count: cachedSize.width * cachedSize.height)
    }
    
    mutating func render(encoder: MTLRenderCommandEncoder, deltaTime: Float) {
        // Foreground
        encoder.setRenderPipelineState(foregroundPSO)
        encoder.setVertexBuffer(foreground.primitive.vertexBuffer,
                                offset: 0,
                                index: 0)
        encoder.setFragmentBytes(&params,
                                 length: MemoryLayout<Params>.stride,
                                 index: 0)
        encoder.setFragmentBuffer(gridState.current, offset: 0, index: 1)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: foreground.primitive.indexCount,
                                      indexType: .uint16,
                                      indexBuffer: foreground.primitive.indexBuffer,
                                      indexBufferOffset: 0)
        
        if cachedSize.width * cachedSize.height <= 256 {
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
    
    mutating func drawableSizeWillChange(size: CGSize) {
        
    }
}

// MARK: - Compute Pipeline
extension GameOfLifeScene {
    private mutating func calculateNextState(encoder: MTLComputeCommandEncoder) {
        // Calculate next step
        encoder.setComputePipelineState(computeTickPSO)
        encoder.setBuffer(gridState.current, offset: 0, index: 0)
        encoder.setBuffer(gridState.next, offset: 0, index: 1)
        encoder.setBytes(&params, length: MemoryLayout<Params>.stride, index: 2)
        
        let threadsPerGroup = MTLSize(width: computeTickPSO.threadExecutionWidth, height: 1, depth: 1)
        let threadsPerGrid = MTLSize(width: Int(params.gridWidth) * Int(params.gridHeight), height: 1, depth: 1)
        encoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        // Update actual buffer
        encoder.setComputePipelineState(computeCopyPSO)
        encoder.setBuffer(gridState.current, offset: 0, index: 0)
        encoder.setBuffer(gridState.next, offset: 0, index: 1)
        encoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
    }
    
    private mutating func spawnPatterns(encoder: MTLComputeCommandEncoder) {
        let threadsPerGroup = MTLSize(width: computeSpawnPSO.threadExecutionWidth, height: 1, depth: 1)
        let threadsPerGrid = MTLSize(width: Int(params.gridWidth) * Int(params.gridHeight), height: 1, depth: 1)
        
        encoder.setComputePipelineState(computeSpawnPSO)
        for pattern in spawnQueue {
            var patternParams = GridPatternParams(
                origin: SIMD2<UInt32>(pattern.origin.x, pattern.origin.y),
                size: uint(pattern.model.points.count / 2)
            )
            var points: [SIMD2<Int32>] = []
            for i in 0..<(pattern.model.points.count / 2) {
                points.append(SIMD2<Int32>(pattern.model.points[2 * i], pattern.model.points[2 * i + 1]))
            }
            let pointsBuffer = hardware.device.makeBuffer(bytes: points, length: MemoryLayout<SIMD2<Int>>.stride * points.count, options: [])
    
            encoder.setBuffer(gridState.current,
                              offset: 0,
                              index: 0)
            encoder.setBytes(&patternParams,
                             length: MemoryLayout<GridPatternParams>.stride,
                             index: 1)
            encoder.setBuffer(pointsBuffer,
                              offset: 0,
                              index: 2)
            encoder.setBytes(&params,
                             length: MemoryLayout<Params>.stride,
                             index: 3)
            encoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        }
        
        spawnQueue.removeAll()
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
    
    private func makeComputeTickPSO() -> MTLComputePipelineState {
        guard let function = hardware.library.makeFunction(name: "game_of_life_tick") else { fatalError() }
        do {
            return try hardware.device.makeComputePipelineState(function: function)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    private func makeComputeCopyPSO() -> MTLComputePipelineState {
        guard let function = hardware.library.makeFunction(name: "game_of_life_copy") else { fatalError() }
        do {
            return try hardware.device.makeComputePipelineState(function: function)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    private func makeComputeSpawnPSO() -> MTLComputePipelineState {
        guard let function = hardware.library.makeFunction(name: "game_of_life_spawn") else { fatalError() }
        do {
            return try hardware.device.makeComputePipelineState(function: function)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
