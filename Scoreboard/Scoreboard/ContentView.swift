//
//  ContentView.swift
//  Scoreboard
//
//  Created by Steve F. on 8/19/20.
//  Copyright © 2020 Steve F. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    
    @State var new_game: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 10) {
                Text("Scoreboard")
                .font(.custom("Chalkduster", size: 50))
                
                Button(action: {
                    self.new_game = true
                }) {
                    Text("New Game")
                    .font(.custom("Chalkduster", size: 20))
                    .foregroundColor(.black)
                }
                
                NavigationLink(destination: CreateGameView(TEST_NAV: self.$new_game), isActive: $new_game) {
                    EmptyView()
                }
                //.isDetailLink(false)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
