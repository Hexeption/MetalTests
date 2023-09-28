//
//  HelloWorldTriangleApp.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 28/09/2023.
//

import SwiftUI

@main
struct HelloWorldTriangleApp: App {
    
    @StateObject private var gameScene = GameScene()
    
    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(gameScene)
        }
    }
}
	
