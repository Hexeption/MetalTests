//
//  ContentView.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 28/09/2023.
//

import SwiftUI
import MetalKit

struct ContentView: UIViewRepresentable {
    
    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<ContentView>) -> some UIView {
        let metalView = MTKView()
        metalView.delegate = context.coordinator
        metalView.preferredFramesPerSecond = 60
        metalView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            metalView.device = metalDevice
        }
        
        metalView.framebufferOnly = false
        metalView.drawableSize = metalView.frame.size
        
        return metalView
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<ContentView>) {
    }
    
}

#Preview {
    ContentView()
}
