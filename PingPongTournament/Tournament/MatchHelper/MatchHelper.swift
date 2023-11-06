//
//  MatchHelper.swift
//  PingPongTournament
//
//  Created by J. Rudin on 13.10.23.
//

import Foundation
import SwiftUI

struct Match: Hashable, Identifiable {
    let id = UUID()
    var players: [String]
    var points: [Int]
    var round: Int
    var winner: Int? = nil
    var finalNumber: Int? = nil
}

struct MockMatch {
    let sampleMatch = Match(players: ["Gaggo", "Schorsch"], points: [0, 0], round: 0)
}

struct MockMatches {
    let matches = [Match(players: ["Gaggo", "Schorsch"], points: [0, 0], round: 0), Match(players: ["Schnauzbueb", "Gaggo"], points: [0, 0], round: 0), Match(players: ["Schorsch", "Schnauzbueb"], points: [7, 11], round: 0)]
}

struct EnterMatchDetailsPopoverView: View {
    @State var match: Match
    @Binding var matchToEdit: Match?
    @ObservedObject var tournamentViewModel: TournamentViewModel
    @State var alertIsShown: Bool = false
    @State var alertText: String = ""
    @State var alertButtonText: String = ""
    @State var success: Bool = false
    @State var update: Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    tournamentViewModel.storePoints(matchId: match.id, points: match.points)
                    matchToEdit = nil
                } label: { Image(systemName: "xmark").foregroundColor(Color(.label)).imageScale(.medium).frame(width: 44, height: 44)
                }.padding()
            }
            Spacer()
            ZStack { // TODO: find a way to align it properly ev with length of text
                HStack {
                    Spacer()
                    Text(match.players[0]).padding(.horizontal)
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("VS").padding(.horizontal)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Text(match.players[1]).padding(.horizontal)
                    Spacer()
                }
            }

            HStack {
                Spacer()
                Picker("Number of Rounds", selection: $match.points[0]) {
                    ForEach(0 ... 50, id: \.self) { number in
                        Text("\(number)")
                    }
                }.pickerStyle(.wheel)
                Text(":")
                Picker("Number of Rounds", selection: $match.points[1]) {
                    ForEach(0 ... 50, id: \.self) { number in
                        Text("\(number)")
                    }
                }.pickerStyle(.wheel)
                Spacer()
            }
            Spacer()
            Button {
                Task {
                    success = update ? await tournamentViewModel.completedMatchUpdate(matchId: match.id, points: match.points, oldPoints: matchToEdit!.points) : await tournamentViewModel.matchCompleted(matchId: match.id, points: match.points)
                    if success {
                        if match.points[0] == 0 {
                            alertIsShown = true
                            alertText = match.players[0] + " du Fläsche"
                            alertButtonText = "True"
                        } else if match.points[1] == 0 {
                            alertIsShown = true
                            alertText = match.players[1] + " du Fläsche"
                            alertButtonText = "True"
                        } else {
                            matchToEdit = nil
                        }
                    } else {
                        alertIsShown = true
                        alertText = "Result not possible, try again"
                        alertButtonText = "OK"
                    }
                }
            } label: { Text("Complete Match").bold().frame(width: 180, height: 50).background(Color.blue.gradient).foregroundColor(Color.white).cornerRadius(10)
            }
            .alert(isPresented: $alertIsShown) {
                Alert(title: Text(alertText),
                      dismissButton: .default(Text(alertButtonText)) { success ? matchToEdit = nil : nil
                      })
            }
            Spacer()
        }
    }
}

final class EnterMatchDetailsViewModel: ObservableObject {
    @Published var isShowingPopup: Bool = false
}
