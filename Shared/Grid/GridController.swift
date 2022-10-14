//
//  GridController.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

final class GridController: NSObject {
    private var config: Config
    private let renderer: Renderer
    private var scene: GridScene
    private let hardware: Hardware = Hardware()
    private var skipTick = false
    
    init(config: Config, view: MTKView) {
        self.config = config
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
    
    func spawn(at location: (x: Float, y: Float)) {
        guard renderer.isPaused else { return }
        skipTick = true
        scene.spawn(pattern: config.pattern, at: location)
        performTick()
    }
}

// MARK: - MTKViewDelegate
extension GridController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        draw()
    }
    
    private func draw() {
        if !skipTick {
            scene.tick()
        }
        renderer.draw(scene: &scene)
        skipTick = false
    }
}

