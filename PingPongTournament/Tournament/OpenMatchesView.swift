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
        if !tournamentViewModel.allMatchesPlayed { // TODO fix this
            List {
                if !tournamentViewModel.playingFinals {
                    ForEach(0 ..< tournamentViewModel.rounds, id: \.self) { round in
                        if tournamentViewModel.matches.filter({ $0.round == round && $0.winner == nil }).isEmpty == false {
                            Section(header:
                                tournamentViewModel.rounds > 1 || tournamentViewModel.mode == ss ? AnyView(
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
                                Text("Final for \(final + 1). place")
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
            // TODO wont enter this one...
            WinnerView(tournamentViewModel: tournamentViewModel)
        }
    }
}

struct WinnerView: View {
    @ObservedObject var tournamentViewModel: TournamentViewModel
    @State var winner: String = ""
    @State private var isPresentingAlert: Bool = false
    @State var isPresentingFinalConfirm: Bool = false
    @State var isPresentingConfirm: Bool = false

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

            tournamentViewModel.playingFinals ?
                AnyView(Text("All matches and finals played").font(.title2).padding().foregroundColor(.secondary)) : AnyView(
                    VStack {
                        Text("All matches played").font(.title2).padding().foregroundColor(.secondary)
                        Text("Add an additional round or").font(.title2).foregroundColor(.secondary)
                    })
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
            Button("Add Round", action: {
                Task {
                    if tournamentViewModel.mode == ss {
                        await tournamentViewModel.sortStatsSwissEndOfRound()
                    }
                    await tournamentViewModel.addRound()
                }
            })
            // only show "play finals" if round robin or enough rounds played that the last could have reached the top
            if tournamentViewModel.mode != ss ||
                (tournamentViewModel.players.count % 2 == 0 && tournamentViewModel.rounds >= tournamentViewModel.players.count / 2) ||
                (tournamentViewModel.players.count % 2 == 1 && tournamentViewModel.rounds >= tournamentViewModel.players.count)

            {
                Button("Play Finals", action: { isPresentingFinalConfirm = true }).confirmationDialog("Are you sure?", isPresented: $isPresentingFinalConfirm) {
                    Button("Yes") {
                        isPresentingFinalConfirm = false
                        Task { await tournamentViewModel.addFinals() }
                    }
                }
            }
            Button("Enough, let \(winner.uppercased()) win", role: .cancel, action: {
                Task {
                    if tournamentViewModel.mode == ss {
                        await tournamentViewModel.sortStatsSwissEndOfRound()
                    }
                }
                tournamentViewModel.finishedWithoutFinals()
            })
        }.alert("Are you sure? You can't add anymore rounds after the finals", isPresented: $isPresentingFinalConfirm) {
            Button("Yes") {
                isPresentingFinalConfirm = false
                Task { await tournamentViewModel.addFinals() }
            }
            Button("No") {
                isPresentingFinalConfirm = false
            }
        }

        .task {
            winner = await tournamentViewModel.getWinner()
            if !tournamentViewModel.playingFinals && !tournamentViewModel.finished {
                isPresentingAlert = true
            }
        }
    }
}
