//
//  Renderer.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

final class Renderer: NSObject {
    var fps: Int {
        set { view.preferredFramesPerSecond = newValue }
        get { view.preferredFramesPerSecond }
    }
    var isPaused: Bool {
        set { view.isPaused = newValue }
        get { view.isPaused }
    }
    private let hardware: Hardware
    private let view: MTKView
    
    init(view: MTKView, hardware: Hardware) {
        self.view = view
        self.hardware = hardware
        super.init()
        view.device = hardware.device
    }
    
    func flush() {
        view.draw()
    }
}

// MARK: - Rendering
extension Renderer {
    func draw(scene: inout GridScene) {
        guard let commandBuffer = hardware.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        
        scene.render(encoder: renderEncoder)
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
