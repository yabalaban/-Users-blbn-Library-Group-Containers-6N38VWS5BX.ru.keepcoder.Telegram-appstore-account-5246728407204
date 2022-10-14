//
//  MetalView.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import SwiftUI
import MetalKit

class Config {
    let gridSize: (Int, Int)
    let fps: Int
    let isPaused: Bool
    let pattern: GameOfLifePattern
    
    init(gridSize: (Int, Int), fps: Int, isPaused: Bool, pattern: GameOfLifePattern) {
        self.gridSize = gridSize
        self.fps = fps
        self.isPaused = isPaused
        self.pattern = pattern
    }
}

class TickCallbackHolder {
    var callback: () -> Void = {}
}

enum MetalViewStyle {
    static let borderWidth: CGFloat = 2
    static let frameSize: CGFloat = 800
}

struct MetalView: View {
    @State private var gridController: GridController
    @State private var metalView: MTKViewPlus
    private let config: Config
    private var tickCallbackHolder: TickCallbackHolder
    
    init(config: Config, tickCallbackHolder: TickCallbackHolder) {
        let view = MTKViewPlus(frame: NSRect(x: 0,
                                             y: 0,
                                             width: MetalViewStyle.frameSize,
                                             height: MetalViewStyle.frameSize))
        _gridController = State(initialValue: GridController(config: config,
                                                             view: view))
        _metalView = State(initialValue: view)
        self.config = config
        self.tickCallbackHolder = tickCallbackHolder
    }
    
    var body: some View {
        VStack {
            MetalViewRepresentable(
                view: $metalView,
                gridController: gridController,
                config: config
            )
        }.onAppear() {
            tickCallbackHolder.callback = {
                gridController.performTick()
            }
            metalView.onTouchCallback = { location in
                gridController.spawn(at: (Float(location.x), Float(location.y)))
            }
        }
    }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
    @Binding var view: MTKViewPlus
    let gridController: GridController?
    let config: Config
    
#if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        return view
    }
    func updateNSView(_ uiView: NSViewType, context: Context) {
        updateMetalView()
    }
#elseif os(iOS)
    func makeUIView(context: Context) -> MTKView {
        view
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        updateMetalView()
    }
#endif
    
    func updateMetalView() {
        gridController?.update(config: config)
    }
}

struct MetalView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MetalView(config: Config(gridSize: (64, 64),
                                     fps: 60,
                                     isPaused: false,
                                     pattern: .pixel),
                      tickCallbackHolder: TickCallbackHolder())
            Text("Metal View")
        }
    }
}

