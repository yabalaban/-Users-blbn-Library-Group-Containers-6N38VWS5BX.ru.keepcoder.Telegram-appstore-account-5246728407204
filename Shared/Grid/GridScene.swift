//
//  GridScene.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

protocol GridScene {
    mutating func clear()
    mutating func tick(encoder: MTLComputeCommandEncoder)
    mutating func render(encoder: MTLRenderCommandEncoder, deltaTime: Float)
    mutating func update(width: Int, height: Int) -> Bool
    mutating func spawn(model: PatternModel, at location: (x: Float, y: Float))
    mutating func drawableSizeWillChange(size: CGSize)
}
