//
//  TournamentView.swift
//  PingPongTournament
//
//  Created by J. Rudin on 07.10.23.
//

import SwiftUI

struct TournamentView: View {
    @Binding var rounds: Int
    @Binding var players: [String]
    @Binding var finals: Bool
    @StateObject var viewModel = TournamentViewModel()
//    @State var matches: [Match] = []
    @Environment(\.dismiss) var dismiss
    @State private var isPresentingConfirm: Bool = false
    @State private var isPresentingAddRound: Bool = false

    var body: some View {
        NavigationView {
            TabView {
                OpenMatchesView(tournamentViewModel: viewModel).tabItem {
                    Image(systemName: "figure.table.tennis")
                    Text("Open").bold()
                }

                PlayedMatchesView(tournamentViewModel: viewModel).tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Played").bold()
                }

                StatsView(tournamentViewModel: viewModel).tabItem {
                    Image(systemName: "medal")
                    Text("Stats").bold()
                }
            }.navigationTitle("")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        if viewModel.tournamentFinished() {
                            Button("Back") { isPresentingConfirm = viewModel.tournamentFinished() }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                                Button("Back to Menu") {
                                    isPresentingConfirm = false
                                    Task {
                                        await viewModel.deleteTournament()
                                    }
                                    dismiss()
                                }
                                Button("Restart") {
                                    isPresentingConfirm = false
                                    viewModel.restartTournament()
                                }
                            }
                        } else {
                            Button("Cancel Tournament") { isPresentingConfirm = !viewModel.tournamentFinished() }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                                Button("Delete Tournament", role: .destructive) {
                                    isPresentingConfirm = false
                                    Task {
                                        await viewModel.deleteTournament()
                                    }
                                    dismiss()
                                }
                                Button("Restart") {
                                    isPresentingConfirm = false
                                    viewModel.restartTournament()
                                }
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if !viewModel.playingFinals { Button("Add round") { isPresentingAddRound = !viewModel.playingFinals }.confirmationDialog("Are you sure?", isPresented: $isPresentingAddRound) {
                            Button("Add additional round") {
                                isPresentingAddRound = false
                                viewModel.addRound()
                            }
                        }
                        }
                    }
                }
                .onAppear {
                    viewModel.setup(rounds: self.rounds, players: self.players, finals: self.finals)
                }
        }
    }
}

struct TournamentView_Previews: PreviewProvider {
    static var previews: some View {
        @State var rounds = 1
        @State var players: [String] = ["Jonas", "Pier", "Andre", "Flo"]
        @State var finals = false
        TournamentView(rounds: $rounds, players: $players, finals: $finals)
    }
}

final class TournamentViewModal: ObservableObject {}