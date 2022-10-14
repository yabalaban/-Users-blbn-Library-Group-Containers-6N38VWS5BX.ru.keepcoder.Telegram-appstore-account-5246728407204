//
//  MTKViewPlus.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 14/10/2022.
//

import MetalKit

final class MTKViewPlus: MTKView {
    #if os(macOS)
    typealias Point = NSPoint
    #elseif os(iOS)
    typealias Point = CGPoint
    #endif
    
    var onTouchCallback: ((Point) -> Void)?
    
    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        onTouchCallback?(self.convert(event.locationInWindow, from: nil))
    }
    #endif
    
    #if os(iOS)
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        onTouchCallback?(touch.location(in: self))
    }
    #endif
}
