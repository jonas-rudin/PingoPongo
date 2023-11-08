//
//  MatchesView.swift
//  PingPongTournament
//
//  Created by J. Rudin on 12.10.23.
//

import SwiftUI

struct OpenMatchesView: View {
    @ObservedObject var tournamentViewModel: TournamentViewModel
    var body: some View {
        VStack {
            HStack {
                Text(tournamentViewModel.playingFinals ? "Open Finals" : "Open Matches").font(.title).bold().padding()
                Spacer()
            }
            Spacer()
            OpenMatchesListView(tournamentViewModel: tournamentViewModel)
            Spacer()
        }
    }
}

struct OpenMatchesView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var viewModel = TournamentViewModel()
        OpenMatchesView(tournamentViewModel: viewModel)
    }
}

struct OpenMatchesListView: View {
    @State private var matchToEdit: Match?
    @ObservedObject var tournamentViewModel: TournamentViewModel
    @State var winner: String = ""
    @State var firstIndex: Int = 0
    @State var lastIndex: Int = 0

    var body: some View {
        if !tournamentViewModel.tournamentFinished() {
            List {
                if !tournamentViewModel.playingFinals {
                    ForEach(0 ..< tournamentViewModel.rounds, id: \.self) { round in // TODO: remove played rounds
                        if tournamentViewModel.matches.filter({ $0.round == round && $0.winner == nil }).isEmpty == false {
                            Section(header:
                                tournamentViewModel.rounds > 1 ? AnyView(
                                    HStack {
                                        Spacer()
                                        Text("Round \(round + 1)")
                                        Spacer()
                                    }
                                ) : AnyView(HStack {})

                            ) {
                                ForEach(tournamentViewModel.matches.filter { $0.round == round && $0.winner == nil }, id: \.id) { match in
                                    ZStack {
                                        HStack {
                                            Text(match.players[0]).padding()
                                            Spacer()
                                        }
                                        Text("\(match.points[0]) : \(match.points[1])")
                                        HStack {
                                            Spacer()
                                            Text(match.players[1]).padding()
                                        }
                                    }.contentShape(Rectangle())
                                        .onTapGesture {
                                            matchToEdit = match
                                        }
                                }
                            }
                        }
                    }
                } else {
                    ForEach(Array(stride(from: 0, to: tournamentViewModel.players.count, by: 2)), id: \.self) { final in
                        if tournamentViewModel.matches.filter({ $0.finalNumber == final && $0.winner == nil }).isEmpty == false {
                            Section(header: HStack {
                                Spacer()
                                Text("Final for \(final + 1). place") // TODO: remove title if played
                                Spacer()
                            }) {
                                ForEach(tournamentViewModel.matches.filter { $0.finalNumber == final && $0.winner == nil }, id: \.id) { match in
                                    ZStack {
                                        HStack {
                                            Text(match.players[0]).padding()
                                            Spacer()
                                        }
                                        Text("\(match.points[0]) : \(match.points[1])")
                                        HStack {
                                            Spacer()
                                            Text(match.players[1]).padding()
                                        }
                                    }.contentShape(Rectangle())
                                        .onTapGesture {
                                            matchToEdit = match
                                        }
                                }
                            }
                        }
                    }
                }
            }.sheet(item: $matchToEdit) { match in
                EnterMatchDetailsPopoverView(match: match, matchToEdit: $matchToEdit, tournamentViewModel: tournamentViewModel)
            }
        } else {
            WinnerView(tournamentViewModel: tournamentViewModel)
        }
    }
}

struct WinnerView: View {
    @ObservedObject var tournamentViewModel: TournamentViewModel
    @State var winner: String = ""
    @State private var isPresentingAlert: Bool = false

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "trophy").resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                Text("\(winner.uppercased())").font(.title).bold().padding()
                Image(systemName: "trophy").resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
            }
            Text("WON THE TOURNAMENT!").font(.title2).bold().padding()
            Spacer()
            Text("All matches played").font(.title2).padding().foregroundColor(.secondary)
            tournamentViewModel.playingFinals ? AnyView(HStack {}) : AnyView(Text("Add an additional round or").font(.title2).foregroundColor(.secondary))
            HStack {
                Text("Go to").font(.title2).foregroundColor(.secondary)
                VStack {
                    Image(systemName: "medal.fill").resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30).foregroundColor(.secondary)
                    Text("Stats").font(.caption).foregroundColor(.secondary)
                }
                Text("to view the results").font(.title2).foregroundColor(.secondary)
            }
            Spacer()
            Spacer()
        }
        .alert("Congratulation! \n \(winner.uppercased()) holds the 1. place!", isPresented: $isPresentingAlert) {
            Button("Play Finals", action: { Task { await tournamentViewModel.addFinals() }})
            Button("Add Round", action: { Task { await tournamentViewModel.addRound() }})
            Button("Enough, let \(winner.uppercased()) win", role: .cancel, action: {})
        }

        .onAppear {
            Task {
                winner = await tournamentViewModel.getWinner()
                if !tournamentViewModel.playingFinals {
                    isPresentingAlert = true
                }
            }
        }
    }
}
