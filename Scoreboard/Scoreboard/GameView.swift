//
//  GameView.swift
//  Scoreboard
//
//  Created by user926153 on 8/21/20.
//  Copyright © 2020 user926153. All rights reserved.
//
//
//

/*
 This uses the TrackableScrollView as created by Max Natchanon here:
https://medium.com/@maxnatchanon/swiftui-how-to-get-content-offset-from-scrollview-5ce1f84603ec
 */

import SwiftUI
import UIKit

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    
    static var defaultValue: [CGFloat] = [0]
    
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

struct TrackableScrollView<Content>: View where Content: View {
    let axes: Axis.Set
    let showIndicators: Bool
    @Binding var contentOffset: CGFloat
    let content: Content
    
    init(_ axes: Axis.Set = .vertical, showIndicators: Bool = true, contentOffset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showIndicators = showIndicators
        self._contentOffset = contentOffset
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { outsideProxy in
            ScrollView(self.axes, showsIndicators: self.showIndicators) {
                ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                    GeometryReader { insideProxy in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(fromOutsideProxy: outsideProxy, insideProxy: insideProxy)])
                            // Send value to the parent
                    }
                    VStack {
                        self.content
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                self.contentOffset = value[0]
            }
            // Get the value then assign to offset binding
        }
    }
    
    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
        if axes == .vertical {
            return (insideProxy.frame(in: .global).minY - outsideProxy.frame(in: .global).minY)
        } else {
            return (insideProxy.frame(in: .global).minX - outsideProxy.frame(in: .global).minX)
        }
    }
}

struct GameView: View {
    // for custom nav button
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var TEST_NAV_GAME: Bool
    
    let row_label_width: CGFloat = 80
    let col_label_height: CGFloat = 60
    let col_width: CGFloat = 75
    let row_height: CGFloat = 55
    
    @ObservedObject var game_settings: GameSettings
    @State var column_offset: CGFloat = 0
    @State var row_offset: CGFloat = 0
    @State var selected_round = -1
    @State var selected_player = -1
    @State var new_score: String = ""
    @State var rounds_id = UUID()
    @State var game_over: Bool = false
    @State var winners: [String] = []
    
    private func AddRound() {
        if self.game_settings.players.count > 0 {
            var new_round: [Int] = []
            for _ in (0...self.game_settings.players.count - 1) {
                new_round.append(0)
            }
            
            self.game_settings.scores.append(new_round)
            self.rounds_id = UUID()
        }
        
    }
    
    
    private func DeleteRound(round: Int) {
        let round_index = round - 1
        for player_index in (0...self.game_settings.players.count - 1) {
            self.game_settings.totals[player_index] -= self.game_settings.scores[round_index][player_index]
        }
        self.game_settings.scores.remove(at: round_index)
    }
    
    private func UpdateScore() {
        if self.new_score.count > 0 {
            let current_score = self.game_settings.scores[self.selected_round][self.selected_player]
            
            let new_score = Int(self.new_score) ?? 0
            
            self.game_settings.totals[self.selected_player] -= current_score
            
            self.game_settings.scores[self.selected_round][self.selected_player] = new_score
            
            self.game_settings.totals[self.selected_player] += new_score
        }
        
        self.selected_player = -1
        self.selected_round = -1
        self.new_score = ""
    }
    
    private func FindWinners() {
        self.winners = []
        
        var winning_score = self.game_settings.totals[0]
        
        // find winning score high or low
        if self.game_settings.high_score_wins {
            for player_index in (0...self.game_settings.players.count - 1) {
                if self.game_settings.totals[player_index] > winning_score {
                    winning_score = self.game_settings.totals[player_index]
                }
            }
        }
        else {
            for player_index in (0...self.game_settings.players.count - 1) {
                if self.game_settings.totals[player_index] < winning_score {
                    winning_score = self.game_settings.totals[player_index]
                }
            }
        }
        
        // find all ties
        for player_index in (0...self.game_settings.players.count - 1) {
            if self.game_settings.totals[player_index] == winning_score {
                self.winners.append(self.game_settings.players[player_index])
            }
        }
    }
    
    
    var body: some View {
        
        // MAIN VIEW
        VStack(spacing: 0) {
            
            // TITLE
            VStack(alignment: .center, spacing: 10) {
                Text(self.game_settings.game_name)
                    .font(.title)
                if self.game_settings.high_score_wins {
                    Text("high score wins")
                }
                else {
                    Text("low score wins")
                }
            }
            
            
            // EDITING + ROUNDS + SCORESHEET
            VStack(spacing: 0) {
                // SCORE EDITING
                HStack(spacing: 20) {
                    if self.selected_round > -1 &&
                       self.selected_player > -1 &&
                       self.selected_player < self.game_settings.players.count &&
                       self.selected_round < self.game_settings.scores.count{
                        Text(self.game_settings.players[self.selected_player])
                        .padding(.leading, 10)
                        Text("Round \(self.selected_round + 1)")
                        TextField("New score", text: $new_score, onCommit: UpdateScore)
                        .keyboardType(.decimalPad)
                    }
                    else {
                        Text("")
                    }
                }
                .frame(height: 40)
                
                // NEW ROUND BUTTON + PLAYER NAMES
                HStack(spacing:0) {
                    
                    // ADD NEW ROUND
                    Button(action: {
                        self.AddRound()
                    }) {
                        Text("New round +")
                        .fixedSize(horizontal: false, vertical: true)
                        
                    }
                    .frame(width: self.row_label_width, height: self.col_label_height)
                    .border(Color.black)
                    
                    // PLAYER COLS
                    TrackableScrollView(.horizontal, showIndicators: true, contentOffset: $column_offset) {
                        HStack(spacing: 0) {
                            if self.game_settings.players.count > 0 {
                                ForEach((0...self.game_settings.players.count - 1), id: \.self) { player_index in
                                    VStack(spacing: 0) {
                                        Text(self.game_settings.players[player_index])
                                        Text("\(self.game_settings.totals[player_index])")
                                    }
                                    .frame(width: self.col_width, height: self.col_label_height)
                                    .border(Color.black)
                                }
                            }
                        }
                    }
                }
                .frame(height: self.col_label_height)
                
                // ROUNDS + MAIN GRID
                HStack(spacing: 0) {
                    
                    TrackableScrollView(.vertical, showIndicators: true, contentOffset: $row_offset) {
                        
                        ForEach((1...self.game_settings.scores.count).reversed(), id: \.self) { round in
                            Text("Round \(round)")
                            .frame(width:self.row_label_width, height: self.row_height)
                            .contextMenu {
                                Button(action: {
                                    if self.game_settings.scores.count > 1 {
                                        self.DeleteRound(round: round)
                                    }
                                }) {
                                    if self.game_settings.scores.count > 1 {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                    else {
                                        Text("Can't delete the only round!")
                                    }
                                }
                            }
                        }
                        .border(Color.black)
                    }
                    .frame(width: self.row_label_width)
                    .id(self.rounds_id)
                    
                    
                    // MAIN GRID
                    Color.clear.overlay(
                        VStack(spacing: 0) {
                            ForEach(self.game_settings.scores.indices.reversed(), id: \.self) { round_index in
                                HStack(spacing: 0) {
                                    ForEach(self.game_settings.scores[0].indices, id: \.self) { player_index in
                                        Text("\(self.game_settings.scores[round_index][player_index])")
                                        .frame(width: self.col_width, height: self.row_height)
                                        .foregroundColor(self.selected_round == round_index &&
                                                self.selected_player == player_index ?
                                                    Color.yellow : Color.black)
                                        .border(self.selected_round == round_index &&
                                                self.selected_player == player_index ?
                                                Color.yellow : Color.black)
                                        .onTapGesture {
                                            self.selected_round = round_index
                                            self.selected_player = player_index
                                        }
                                            
                                    }
                                }
                                .frame(height: self.row_height)
                            }
                            Spacer()
                        }
                        .offset(x: self.column_offset, y: self.row_offset)
                        , alignment: .topLeading
                    )
                    .clipped()
                }
            }
            
            Button(action: {
                self.FindWinners()
                self.game_over = true
            }) {
                Text("End Game")
            }
            .frame(height: 70)
            
            NavigationLink(destination: CongratulationsView(TEST_HOME: self.$TEST_NAV_GAME, winners: self.winners), isActive: $game_over) {
                EmptyView()
            }
            //.isDetailLink(false)
        }
        /*
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            Button(action: {
                self.game_settings.game_in_progress = true
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.pencil")
                    Text("Edit game")
                    Spacer()
                }
            }
        )
        */
    }
}

#if DEBUG

struct GameView_Previews: PreviewProvider {
    
    static var previews: some View {
        GameView(TEST_NAV_GAME: .constant(true), game_settings: GameSettings())
    }
}
#endif

