//
//  MatchesView.swift
//  PingPongTournament
//
//  Created by J. Rudin on 12.10.23.
//

import SwiftUI

struct PlayedMatchesView: View {
    @ObservedObject var tournamentViewModel: TournamentViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Played Matches").font(.title).bold().padding()
                Spacer()
            }
            Spacer()
            PlayedMatchesListView(tournamentViewModel: tournamentViewModel)
            Spacer()
        }
    }
}

struct PlayedMatchesListView: View {
    @State private var matchToEdit: Match?
    @ObservedObject var tournamentViewModel: TournamentViewModel

    var body: some View {
        if tournamentViewModel.tournamentStarted() {
            List {
                ForEach(0 ..< tournamentViewModel.rounds, id: \.self) { round in // TODO: remove played rounds
                    if tournamentViewModel.matches.filter({ $0.round == round && $0.winner != nil && $0.finalNumber == nil }).isEmpty == false {
                        Section(header:
                            tournamentViewModel.rounds > 1 ? AnyView(
                                HStack {
                                    Spacer()
                                    Text("Round \(round + 1)")
                                    Spacer()
                                }
                            ) : AnyView(HStack {})

                        ) {
                            ForEach(tournamentViewModel.matches.filter { $0.round == round && $0.winner != nil }, id: \.id) { match in
                                ZStack {
                                    HStack {
                                        Text(match.players[0]).fontWeight(match.winner == 0 ? .bold : .regular).padding()
                                        Spacer()
                                    }
                                    Text("\(match.points[0]) : \(match.points[1])")
                                    HStack {
                                        Spacer()
                                        Text(match.players[1]).fontWeight(match.winner == 0 ? .bold : .regular).padding()
                                    }
                                }.contentShape(Rectangle())
                                    .onTapGesture {
                                        matchToEdit = match
                                    }
                            }
                        }
                    }
                }
                if tournamentViewModel.playingFinals {
                    ForEach(Array(stride(from: 0, to: tournamentViewModel.players.count, by: 2)), id: \.self) { final in
                        if tournamentViewModel.matches.filter({ $0.finalNumber == final && $0.winner != nil }).isEmpty == false {
                            Section(header: HStack {
                                Spacer()
                                Text("Final for \(final + 1). place") // TODO: remove title if played
                                Spacer()
                            }) {
                                ForEach(tournamentViewModel.matches.filter { $0.finalNumber == final && $0.winner != nil }, id: \.id) { match in
                                    ZStack {
                                        HStack {
                                            Text(match.players[0]).fontWeight(match.winner == 0 ? .bold : .regular).padding()
                                            Spacer()
                                        }
                                        Text("\(match.points[0]) : \(match.points[1])")
                                        HStack {
                                            Spacer()
                                            Text(match.players[1]).fontWeight(match.winner == 0 ? .bold : .regular).padding()
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
            }.sheet(item: $matchToEdit) { match in EnterMatchDetailsPopoverView(match: match, matchToEdit: $matchToEdit, tournamentViewModel: tournamentViewModel, update: true)
            }
        }
        else {
            VStack {
                Text("No matches played").font(.title2).foregroundColor(.secondary)
                HStack {
                    Text("Go to").font(.title2).foregroundColor(.secondary)
                    VStack {
                        Image(systemName: "figure.table.tennis").resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30).foregroundColor(.secondary)
                        Text("Open").font(.caption).foregroundColor(.secondary)
                    }
                    Text("to start the tournament.").font(.title2).foregroundColor(.secondary)
                }
            }
        }
    }
}
