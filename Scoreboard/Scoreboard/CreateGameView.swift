//
//  CreateGameView.swift
//  Scoreboard
//
//  Created by user179118 on 9/1/20.
//  Copyright © 2020 user926153. All rights reserved.
//

import SwiftUI

class GameSettings: ObservableObject {
    let max_game_name_length: Int = 20
    let max_player_name_length: Int = 8
    @Published var game_name: String = "" {
        didSet {
            if game_name.count > max_game_name_length {
                self.game_name = String(self.game_name.prefix(max_game_name_length))
            }
        }
    }
    @Published var high_score_wins: Bool = true
    @Published var players: [String] = []
    @Published var current_player: String = "" {
        didSet {
            if current_player.count > max_player_name_length {
                self.current_player = String(self.current_player.prefix(max_player_name_length))
            }
        }
    }
    
    var totals: [Int] = []
    @Published var scores: [[Int]] = [[]]
    
    var game_in_progress = false
}


struct CreateGameView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var TEST_NAV: Bool
    
    let main_font = ""
    let secondary_font = ""
    let button_color = Color.blue
    let error_color = Color.red
    let max_players = 25
    
    @ObservedObject var settings = GameSettings()
    
    @State var player_error: String = ""
    @State var player_add_success: String = ""
    @State var game_name_error: String = ""
    @State var ready_to_start: Bool = false
    
    
    private func IsGameNameUnique() {
        // NOTE: Only gets called when player hits return from textfield
        
        // TODO: enforce that the game name is unique, either check the DB table each time, or cache the DB names upfront and check against that
        
    }
    
    private func DeletePlayer(at offsets: IndexSet) {
        self.settings.players.remove(atOffsets: offsets)
        self.settings.totals.remove(atOffsets: offsets)
        for round_index in (0...self.settings.scores.count - 1) {
            self.settings.scores[round_index].remove(atOffsets: offsets)
        }
    }
    
    
    private func AddPlayer() {
        
        self.settings.current_player = self.settings.current_player.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if self.settings.current_player.count == 0 {
            self.player_error = "* player name invalid"
        }
        else if self.settings.players.contains(self.settings.current_player) {
            self.player_error = "* player name already added"
        }
        else if self.settings.players.count == self.max_players {
            self.player_error = "* only \(self.max_players) players allowed"
        }
        else {
            self.settings.players.append(self.settings.current_player)
            self.settings.totals.append(0)
            for round_index in (0...self.settings.scores.count - 1) {
                self.settings.scores[round_index].append(0)
            }
            
            self.player_error = ""
            self.player_add_success = "* \(self.settings.current_player) added to game"
            self.settings.current_player = ""
        }
    }
    
    private func StartGame() -> Bool {
        var start = true
        
        self.settings.game_name = self.settings.game_name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if self.settings.players.count == 0 {
            self.player_error = "* please add players to the game"
            start = false
        }
        else {
            self.player_error = ""
            self.player_add_success = ""
            self.settings.current_player = ""
        }
        
        if self.settings.game_name.count == 0 {
            self.game_name_error = "* name the game first!"
            start = false
        }
        /*else if !self.IsGameNameUnique() {
            self.game_cant_start_warning = "* game name already in use"
            start = false
        }
         */
        else {
            self.game_name_error = ""
        }
        
        return start
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            // GAME NAME
            VStack(spacing: 5) {
                Text("Game name:")
                
                // GAME NAME ERROR
                Text(self.game_name_error)
                    .frame(height: 20)
                    .foregroundColor(self.error_color)
                
                TextField("Enter up to \(self.settings.max_game_name_length) characters", text: $settings.game_name)
                .multilineTextAlignment(.center)
            }
            .padding(.bottom, 60)
            
            // HI/LO SCORE WINS
            Toggle(isOn: $settings.high_score_wins) {
                if self.settings.high_score_wins {
                    Text("High Score Wins")
                }
                else {
                    Text("Low Score Wins")
                }
            }
            .frame(width: 300)
            .padding(.bottom, 60)
            
            
            // PLAYER LIST
            VStack(spacing: 10) {
                // TITLE
                Text("Players:")
                
                // PLAYER ERROR
                if self.player_error.count > 0 {
                    Text(self.player_error)
                    .frame(height: 20)
                    .foregroundColor(self.error_color)
                }
                else if self.player_add_success.count > 0 {
                    Text(self.player_add_success)
                    .frame(height: 20)
                    .foregroundColor(Color.green)
                }
                else {
                    Text("")
                    .frame(height: 20)
                }
                
                
                
                // PLAYER ENTRY FIELD
                HStack {
                    TextField("Enter up to \(self.settings.max_player_name_length) characters", text: $settings.current_player)
                    .multilineTextAlignment(.center)
                        
                    Button(action: {
                        self.AddPlayer()
                    }) {
                        Text("Add +")
                    }
                    .frame(width: 100, height: 35)
                }
                
                // LIST OF PLAYERS
                List {
                    ForEach(self.settings.players, id: \.self) { player in
                        Text(player)
                        .font(.custom(self.secondary_font, size: 20))
                    }
                    .onDelete(perform: self.DeletePlayer)
                }
            }
            
            
            
            Button(action: {
                self.ready_to_start = self.StartGame()
            }) {
                if self.settings.game_in_progress {
                    Text("Continue Game")
                    .font(.custom(self.main_font, size: 30))
                    .foregroundColor(self.button_color)
                }
                else {
                    Text("Start Game")
                    .font(.custom(self.main_font, size: 30))
                    .foregroundColor(self.button_color)
                }
                
            }
            .padding([.top, .bottom], 20)
            
            
            NavigationLink(destination: GameView(TEST_NAV_GAME: self.$TEST_NAV, game_settings: self.settings), isActive: $ready_to_start) {
                EmptyView()
            }
            //.isDetailLink(false)
            
            Spacer()
        }
        /*
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "xmark.circle")
                    Text("cancel")
                    Spacer()
                }
            }
        )
        */
    }
}

#if DEBUG
struct CreateGameView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGameView(TEST_NAV: .constant(true))
    }
}
#endif
