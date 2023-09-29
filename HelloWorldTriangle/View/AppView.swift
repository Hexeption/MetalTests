//
//  AppView.swift
//  HelloWorldTriangle
//
//  Created by Keir Davis on 28/09/2023.
//

import SwiftUI

struct AppView: View {
    
    @EnvironmentObject var gameScene: GameScene
    
    var body: some View {
        VStack {
            Text("Demo")
            
            ContentView()
                .frame(width: 800, height: 600)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            gameScene.strafePlayer(offset: gesture.translation)
                        }
                )
            Text("Debug Info")
        }
        VStack {
            Text("Camera")
            HStack {
                Text("Position")
                VStack {
                    Text(String(gameScene.player.position![0]))
                    Text(String(gameScene.player.position![1]))
                    Text(String(gameScene.player.position![2]))
                }
                Text("Distance")
                Text(String(simd.length(gameScene.player.position!)))
                Text("Forwards")
                VStack {
                    Text(String(gameScene.player.forwards![0]))
                    Text(String(gameScene.player.forwards![1]))
                    Text(String(gameScene.player.forwards![2]))
                }
                Text("Right")
                VStack {
                    Text(String(gameScene.player.right![0]))
                    Text(String(gameScene.player.right![1]))
                    Text(String(gameScene.player.right![2]))
                }
                Text("Up")
                VStack {
                    Text(String(gameScene.player.up![0]))
                    Text(String(gameScene.player.up![1]))
                    Text(String(gameScene.player.up![2]))
                }
            }
        }.scaledToFit()
            .fontWidth(.condensed)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GameScene())
    }
}
