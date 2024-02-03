//
//  Test.swift
//  PingPongTournament
//
//  Created by J. Rudin on 27.12.2023.
//

import Foundation
import SwiftUI

struct StatsListView: View {
    @State private var statsToShow: Stats?
    @State var playerStats: PlayerStats?
    @ObservedObject var tournamentViewModel: TournamentViewModel
    @State private var sortOrder = [KeyPathComparator(\Stats.win)]
    var body: some View {
        HStack {
            Image(systemName: "trophy").bold().frame(width: 50)
            Text("Player").bold()
            Spacer()
            Text("Win").bold().frame(width: 50)
            Text("Loss").bold().frame(width: 50)
            Text("Diff").bold().frame(width: 50)
        }.padding(.horizontal, 40)
        List {
            ForEach(Array(tournamentViewModel.stats.enumerated()), id: \.element) { index, stats in
                ZStack {
                    if index == 0 && stats.win > 0 {
                        HStack {
                            Text("\(index + 1)").frame(width: 50).bold()
                            Text(stats.player).bold()
                            Spacer()
                            Text("\(stats.win)").frame(width: 50).bold()
                            Text("\(stats.loss)").frame(width: 50).bold()
                            Text("\(stats.pointsMade - stats.pointsReceived)").frame(width: 50).bold()
                        }
                    } else {
                        HStack {
                            Text("\(index + 1)").frame(width: 50)
                            Text(stats.player)
                            Spacer()
                            Text("\(stats.win)").frame(width: 50)
                            Text("\(stats.loss)").frame(width: 50)
                            Text("\(stats.pointsMade - stats.pointsReceived)").frame(width: 50)
                        }
                    }
                }.contentShape(Rectangle())
                    .onTapGesture {
                        statsToShow = stats
                    }
            }
        }.popover(item: $statsToShow) { stats in
            PlayerMatchDetailsView(stats: stats, statsToShow: $statsToShow, playerStats: tournamentViewModel.playerStats.first(where: { $0.player == stats.player }), tournamentViewModel: tournamentViewModel)
        }
    }
}
