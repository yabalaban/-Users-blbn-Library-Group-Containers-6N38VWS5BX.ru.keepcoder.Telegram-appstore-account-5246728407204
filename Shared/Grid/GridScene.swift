//
//  GridScene.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

protocol GridScene {
    mutating func clear()
    mutating func tick()
    mutating func render(encoder: MTLRenderCommandEncoder)
    mutating func spawn(pattern: GameOfLifePattern, at location: (x: Float, y: Float))
    mutating func update(width: Int, height: Int) -> Bool
}
