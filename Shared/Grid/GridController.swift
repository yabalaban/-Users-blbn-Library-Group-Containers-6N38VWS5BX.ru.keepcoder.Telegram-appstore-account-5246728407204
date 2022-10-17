//
//  GridController.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

final class GridController: NSObject {
    private static var controller: GridController?
    private let hardware: Hardware = Hardware()
    private let modelsStorage: PatternModelsStorage
    private let renderer: Renderer
    private var config: Config
    private var scene: GridScene
    private var lastTime: Float = 0.0
    
    static func make(config: Config, view: MTKView, modelsStorage: PatternModelsStorage = PatternModelsStorage.shared) -> GridController {
        if Self.controller == nil {
            Self.controller = GridController(config: config, view: view, modelsStorage: modelsStorage)
        }
        return Self.controller!
    }
    
    init(config: Config, view: MTKView, modelsStorage: PatternModelsStorage = PatternModelsStorage.shared) {
        self.config = config
        self.modelsStorage = modelsStorage
        renderer = Renderer(view: view, hardware: hardware)
        scene = GameOfLifeScene(view: view, hardware: hardware)
        super.init()
        update(config: config)
        view.delegate = self
    }
    
    func update(config: Config) {
        self.config = config
        renderer.fps = config.fps
        renderer.isPaused = config.isPaused
        if scene.update(width: config.gridSize.0, height: config.gridSize.1) {
            performTick()
        }
    }
    
    func performTick() {
        guard renderer.isPaused else { return }
        renderer.flush()
    }
    
    func clear() {
        scene.clear()
        performTick()
    }
    
    func spawn(pattern: String, at location: (x: Float, y: Float)) {
        guard renderer.isPaused else { return }
        guard let model = modelsStorage.pattern(for: pattern) else { return }
        scene.spawn(model: model, at: location)
        performTick()
    }
}

// MARK: - MTKViewDelegate
extension GridController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        draw()
    }
    
    private func draw() {
        let current = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(current) - lastTime
        lastTime = deltaTime
        renderer.tick(scene: &scene)
        renderer.draw(scene: &scene, deltaTime: deltaTime)
    }
}

