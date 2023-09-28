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
        ContentView()
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        gameScene.spinPlayer(offset: gesture.translation)
                    }
            )
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GameScene())
    }
}
