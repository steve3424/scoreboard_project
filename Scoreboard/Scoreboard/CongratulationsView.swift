//
//  CongratulationsView.swift
//  Scoreboard
//
//  Created by user179118 on 9/1/20.
//  Copyright © 2020 user926153. All rights reserved.
//

import SwiftUI

struct CongratulationsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var TEST_HOME: Bool
    
    let winners: [String]
    
    var body: some View {
        VStack(alignment: .center) {
            Text("CONGRATS!!")
                .font(.title)
            ForEach((0...self.winners.count - 1), id: \.self) {
                player_index in
                Text(self.winners[player_index])
            }
        }
        /*
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            Button(action: {
                self.TEST_HOME = false
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "house.fill")
                    Text("Home")
                    Spacer()
                }
            }
        )
        */
    }
    
}

struct CongratulationsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsView(TEST_HOME: .constant(true), winners: [])
    }
}
