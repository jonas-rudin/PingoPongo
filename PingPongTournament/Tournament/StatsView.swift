//
//  StatsView.swift
//  PingPongTournament
//
//  Created by J. Rudin on 12.10.23.
//

import Charts
import SwiftUI

struct StatsView: View {
    @ObservedObject var tournamentViewModel: TournamentViewModel
    var body: some View {
        VStack {
            HStack {
                Text("Stats").font(.title).bold().padding()
                Spacer()
            }
            Spacer()
            StatsListView(tournamentViewModel: tournamentViewModel)
            Spacer()
        }.onAppear {
            Task {
                await tournamentViewModel.sortStats()
            }
        }
    }
}

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
        }.popover(item: $statsToShow) { stats in PlayerMatchDetailsView(stats: stats, statsToShow: $statsToShow, playerStats: tournamentViewModel.playerStats.first(where: { $0.player == stats.player }))
        }
    }
}

struct PlayerMatchDetailsView: View {
    @State var stats: Stats
    @Binding var statsToShow: Stats?
    @State var playerStats: PlayerStats?
    @State var alertIsShown: Bool = false
    @State var alertText: String = ""
    @State var alertButtonText: String = ""
    @State var success: Bool = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    statsToShow = nil
                } label: { Image(systemName: "xmark").foregroundColor(Color(.label)).imageScale(.medium).frame(width: 44, height: 44)
                }.padding()
            }
            playerStats != nil
                ? AnyView(PlayerStatsListView(stats: stats, playerStats: playerStats!))
                : AnyView(ErrorView())

            Spacer()
        }
    }
}

struct PlayerStatsListView: View {
    @State var stats: Stats
    @State var playerStats: PlayerStats

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(stats.player + "-Stats").font(.title2).bold()
                Spacer()
            }
            Spacer()
            Spacer()
            HStack {
                //            Image(systemName: "medal").bold().frame(width: 50)
                Text("Players").bold()
                Spacer()
                Text("Win").bold().frame(width: 50)
                Text("Loss").bold().frame(width: 50)
                Text("Pts+").bold().frame(width: 50)
                Text("Pts-").bold().frame(width: 50)
            }.padding(.horizontal, 40)
            VStack {
                List {
                    Section { HStack {
                        Text("Total").bold()
                        Spacer()
                        Text("\(stats.win)").bold().frame(width: 50)
                        Text("\(stats.loss)").bold().frame(width: 50)
                        Text("\(stats.pointsMade)").bold().frame(width: 50)
                        Text("\(stats.pointsReceived)").bold().frame(width: 50)
                    }}
                    Section {
                        ForEach(playerStats.oponents, id: \.self) { stats in
                            HStack {
                                Text(stats.player)
                                Spacer()
                                Text("\(stats.win)").frame(width: 50)
                                Text("\(stats.loss)").frame(width: 50)
                                Text("\(stats.pointsMade)").frame(width: 50)
                                Text("\(stats.pointsReceived)").frame(width: 50)
                            }
                        }
                    }
                }.frame(minHeight: CGFloat(52 * (playerStats.oponents.count + 1)))
                Spacer()
                playerStats.winLoss.count > 1 ? AnyView(WinLossChartView(winLoss: playerStats.winLoss)) : AnyView(Spacer())
            }
        }
    }
}

struct WinLossChartView: View {
    @State var winLoss: [Int]
    @State var last: Int = 0

    var body: some View {
        VStack {
            Text("Win-Loss Chart").font(.title2)
            Chart {
                ForEach(Array(winLoss.enumerated()), id: \.element) { i, wL in
                    LineMark(x: PlottableValue.value("Match", i), y: PlottableValue.value("WinLoss", wL))
                }
            }.chartXAxisLabel(position: .bottom, alignment: .center) {
                Text("Matches Played")
            }.chartYAxisLabel(position: .trailing, alignment: .center) {
                Text("Win-Loss")
            }.chartYScale(range: .plotDimension(padding: 30)).padding(.horizontal)
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var viewModel = TournamentViewModel()
        StatsView(tournamentViewModel: viewModel)
    }
}
