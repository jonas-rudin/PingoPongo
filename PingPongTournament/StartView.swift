//
//  File.swift
//  PingPongTournament
//
//  Created by J. Rudin on 06.10.23.
//

import Combine
import Foundation
import SwiftUI

struct StartView: View {
    let maxUsernameLength = 10
    @State var rounds: Int = 1
    @State var inputPlayer: String = ""
    @Binding var players: [String]

    var body: some View {
        VStack {
            Text("").navigationTitle("Tournament Setup")
            Text("Number of Rounds")

            Picker("Number of Rounds", selection: $rounds) {
                ForEach(1 ... 10, id: \.self) { number in
                    Text("\(number)")
                }
            }.pickerStyle(.menu)

            Text("Enter Player Name")

            HStack { TextField("Player Name", text: $inputPlayer).autocorrectionDisabled().onReceive(Just(inputPlayer)) { _ in limitText(maxUsernameLength) }.padding()
                Button("Add Player") {
                    if inputPlayer != "" && !self.players.contains(inputPlayer) && inputPlayer != "-1" {
                        self.players.append(inputPlayer)
                        inputPlayer = ""
                    }
                }.padding()
            }.padding([.horizontal], 20)

            List {
                ForEach(players.prefix(20), id: \.self) { user in
                    Text(user)
                }
                .onDelete(perform: delete)
            }

            Spacer()
            if players.count >= 2 {
                NavigationLink(destination: TournamentView(rounds: self.$rounds, players: self.$players).navigationBarBackButtonHidden(true)
                ) {
                    Text("Let's Go!").bold().frame(width: 180, height: 50).background(Color.blue).foregroundColor(Color.white).cornerRadius(10)
                }
                .padding()
            }
        }
    }

    func delete(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }

    func limitText(_ max: Int) {
        if inputPlayer.count > max {
            inputPlayer = String(inputPlayer.prefix(max))
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        @State var players: [String] = []
        StartView(players: $players)
    }
}
