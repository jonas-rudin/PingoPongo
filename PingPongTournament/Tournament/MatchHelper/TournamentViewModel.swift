//
//  TournamentViewModel.swift
//  PingPongTournament
//
//  Created by J. Rudin on 15.10.2023.
//

import SwiftUI

@MainActor
final class TournamentViewModel: ObservableObject {
    var rounds: Int
    var players: [String]
    var mode: String
    private var originalRounds: Int
    @Published var numberOfMatches: Int
    @Published var numberOfMatchesPerRound: Int
    @Published var numberOfPlayedMatches: Int
    @Published var matches: [Match]
    @Published var stats: [Stats]
    @Published var playerStats: [PlayerStats]
    @Published var playingFinals: Bool
    @Published var finished: Bool
    @Published var allMatchesPlayed: Bool
    
    init() {
        self.rounds = 0
        self.players = []
        self.mode = ""
        self.originalRounds = 0
        self.numberOfMatches = 0
        self.numberOfMatchesPerRound = 0
        self.numberOfPlayedMatches = 0
        self.matches = []
        self.stats = []
        self.playerStats = []
        self.playingFinals = false
        self.finished = false
        self.allMatchesPlayed = false
    }

    func setup(rounds: Int, players: [String], mode: String) {
        self.rounds = rounds
        self.players = players
        self.mode = mode
        self.originalRounds = rounds
        self.playingFinals = false
        self.numberOfMatchesPerRound = mode == rr ? ((players.count - 1) * players.count) / 2 : Int(floor(Double(players.count) / 2.0))
        self.numberOfMatches = self.numberOfMatchesPerRound * rounds
        self.stats = []
        self.playerStats = []
        self.matches = self.initiateMatches()
        self.finished = false
        self.allMatchesPlayed = false
    }

    // initiate matches with round robin tournament
    private func initiateMatches() -> [Match] {
        var matches: [Match] = []
        var players: [String] = self.players
       
        let oponent: [OponentStats] = self.players.map { elem in
            OponentStats(player: elem)
        }
        // Initiate Stats and PlayerStats
        for player in self.players {
            self.stats.append(Stats(player: player))
            self.playerStats.append(PlayerStats(player: player, oponents: oponent.filter { $0.player != player }))
        }
        
        if players.count % 2 != 0 {
            players.append("-1")
        }
        
        if self.mode == ss {
            // Swiss System
            for i in stride(from: 0, to: players.count - 1, by: 2) {
                if players[i] != "-1" && players[i + 1] != "-1" {
                    matches.append(Match(players: [players[i], players[i + 1]], points: [0, 0], round: 0))
                }
            }
            return matches
            
        } else {
            // Round Robin
            let numPlayersMin2 = players.count - 2
            for round in 0..<self.rounds {
                for _ in 0..<players.count - 1 {
                    for i in 0..<(players.count / 2) {
                        if players[i] != "-1" && players[players.count - 1 - i] != "-1" {
                            matches.append(Match(players: [players[i], players[players.count - 1 - i]], points: [0, 0], round: round))
                        }
                    }
                    // Rotate the players list, keeping the first player fixed
                    players = [players[0]] + Array(players.suffix(numPlayersMin2)) + [players[1]]
                }
            }
            
            return matches
        }
    }
    
    func addRound() async {
        self.rounds += 1
        self.allMatchesPlayed = false

        if self.mode == ss {
            var players: [String] = self.stats.map { $0.player }

            if self.rounds % 2 == 0 {
                if players.count % 2 != 0 {
                    players.insert("-1", at: 0)
                }
            } else {
                if players.count % 2 != 0 {
                    players.append("-1")
                }
            }
            for i in stride(from: 0, to: players.count - 1, by: 2) {
                if players[i] != "-1" && players[i + 1] != "-1" {
                    self.matches.append(Match(players: [players[i], players[i + 1]], points: [0, 0], round: self.rounds - 1))
                    self.numberOfMatches += 1
                }
            }
        } else {
            var players: [String] = self.players

            if players.count % 2 != 0 {
                players.append("-1")
            }
            let numPlayersMin2 = players.count - 2

            for _ in 0..<players.count - 1 {
                for i in 0..<(players.count / 2) {
                    if players[i] != "-1" && players[players.count - 1 - i] != "-1" {
                        self.matches.append(Match(players: [players[i], players[players.count - 1 - i]], points: [0, 0], round: self.rounds - 1))
                        self.numberOfMatches += 1
                    }
                }
                // Rotate the players list, keeping the first player fixed
                players = [players[0]] + Array(players.suffix(numPlayersMin2)) + [players[1]]
            }
        }
        self.finished = false
    }
    
    func addFinals() async {
        for i in stride(from: 0, to: self.stats.count - 1, by: 2) {
            await self.sortStatsRoundRobin()
            self.numberOfMatches += 1
            self.matches.append(Match(players: [self.stats[i].player, self.stats[i + 1].player], points: [0, 0], round: self.rounds, finalNumber: i))
        }
        self.playingFinals = true
        self.allMatchesPlayed = false
    }
    
    func matchCompleted(matchId: UUID, points: [Int]) async -> Bool {
        var success = false
        let index = self.matches.firstIndex(where: { $0.id == matchId })!
        
        let winner = points[0] > points[1] ? 0 : 1
        let loser = (1 - winner) % 2
        self.matches[index].winner = winner
        self.matches[index].points = points
        
        for winnerPoints in [11, 21] {
            if points[winner] == winnerPoints {
                if points[loser] <= winnerPoints - 2 || points[loser] == winnerPoints + 2 {
                    success = true
                    break
                }
            }
            
            else if points[winner] > winnerPoints {
                if points[winner] == points[loser] + 2 {
                    success = true
                    break
                }
            }
            if !self.playingFinals {
                break
            }
        }
        
        if success {
            self.numberOfPlayedMatches += 1
            if self.numberOfPlayedMatches == self.numberOfMatches {
                self.allMatchesPlayed = true
            }
            // update stats
            self.stats = self.stats.map { s in
                if s.player == self.matches[index].players[winner] {
                    // update winner
                    return Stats(player: s.player, win: s.win + 1, loss: s.loss, pointsMade: s.pointsMade + points[winner], pointsReceived: s.pointsReceived + points[loser])
                } else if s.player == self.matches[index].players[loser] {
                    // update loser
                    return Stats(player: s.player, win: s.win, loss: s.loss + 1, pointsMade: s.pointsMade + points[loser], pointsReceived: s.pointsReceived + points[winner])
                } else {
                    return s
                }
            }
            
            // switch for swiss system
            if self.mode == ss {
                let winnerIndex = self.stats.firstIndex(where: { $0.player == self.matches[index].players[winner] })
                let loserIndex = self.stats.firstIndex(where: { $0.player == self.matches[index].players[loser] })
                if winnerIndex! > loserIndex! {
                    self.stats.swapAt(winnerIndex!, loserIndex!)
                }
            }
            
            // update playerStats
            self.playerStats = self.playerStats.map { pS in
                if pS.player == self.matches[index].players[winner] {
                    // update winner PlayerStats
                    let oponents: [OponentStats] = pS.oponents.map { o in
                        // update OponentStats of winner's PlayerStats
                        if o.player == self.matches[index].players[loser] {
                            return OponentStats(player: o.player, win: o.win + 1, loss: o.loss, pointsMade: o.pointsMade + points[winner], pointsReceived: o.pointsReceived + points[loser])
                        } else {
                            return o
                        }
                    }
                    var winLoss = pS.winLoss
                    winLoss.append(winLoss.last! + 1)
                    var matchIds = pS.matchIds
                    matchIds.append(self.matches[index].id)
                    return PlayerStats(player: pS.player, oponents: oponents, winLoss: winLoss, matchIds: matchIds)
                } else if pS.player == self.matches[index].players[loser] {
                    // update loser PlayerStats
                    let oponents: [OponentStats] = pS.oponents.map { o in
                        // update OponentStats of loser's PlayerStats
                        if o.player == self.matches[index].players[winner] {
                            return OponentStats(player: o.player, win: o.win, loss: o.loss + 1, pointsMade: o.pointsMade + points[loser], pointsReceived: o.pointsReceived + points[winner])
                        } else {
                            return o
                        }
                    }
                    var winLoss = pS.winLoss
                    winLoss.append(winLoss.last! - 1)
                    var matchIds = pS.matchIds
                    matchIds.append(self.matches[index].id)
                    return PlayerStats(player: pS.player, oponents: oponents, winLoss: winLoss, matchIds: matchIds)
                } else {
                    return pS
                }
            }
        } else {
            self.matches[index].winner = nil
            self.matches[index].points = [0, 0]
        }
        return success
    }
    
    func completedMatchUpdate(matchId: UUID, points: [Int], oldPoints: [Int]) async -> Bool {
        if self.playingFinals {
            return true
        }
        let success = await self.matchCompleted(matchId: matchId, points: points)
        if success {
            // reverse old match
            let index = self.matches.firstIndex(where: { $0.id == matchId })!

            let winner = oldPoints[0] > oldPoints[1] ? 0 : 1
            let newWinner = points[0] > points[1] ? 0 : 1
            let loser = (1 - winner) % 2

            // revert stats for old match
            self.stats = self.stats.map { s in
                if s.player == self.matches[index].players[winner] {
                    // revert winner
                    return Stats(player: s.player, win: s.win - 1, loss: s.loss, pointsMade: s.pointsMade - oldPoints[winner], pointsReceived: s.pointsReceived - oldPoints[loser])
                } else if s.player == self.matches[index].players[loser] {
                    // revert loser
                    return Stats(player: s.player, win: s.win, loss: s.loss - 1, pointsMade: s.pointsMade - oldPoints[loser], pointsReceived: s.pointsReceived - oldPoints[winner])
                } else {
                    return s
                }
            }
            
            // Swissmode, no more update
                
            // revert playerStats for old match
            self.playerStats = self.playerStats.map { pS in
                if pS.player == self.matches[index].players[winner] {
                    // revert winner PlayerStats
                    let oponents: [OponentStats] = pS.oponents.map { o in
                        // revert OponentStats of winner's PlayerStats
                        if o.player == self.matches[index].players[loser] {
                            return OponentStats(player: o.player, win: o.win - 1, loss: o.loss, pointsMade: o.pointsMade - oldPoints[winner], pointsReceived: o.pointsReceived - oldPoints[loser])
                        } else {
                            return o
                        }
                    }
                    var winLoss = pS.winLoss
                    if newWinner == winner {
                        winLoss.remove(at: winLoss.count - 1)
                    } else {
                        winLoss.remove(at: winLoss.count - 2)
                        winLoss.remove(at: winLoss.count - 1)
                        winLoss.append(winLoss.last! - 1)
                    }
                    return PlayerStats(player: pS.player, oponents: oponents, winLoss: winLoss, matchIds: pS.matchIds)
                } else if pS.player == self.matches[index].players[loser] {
                    // revert loser PlayerStats
                    let oponents: [OponentStats] = pS.oponents.map { o in
                        // revert OponentStats of loser's PlayerStats
                        if o.player == self.matches[index].players[winner] {
                            return OponentStats(player: o.player, win: o.win, loss: o.loss - 1, pointsMade: o.pointsMade - oldPoints[loser], pointsReceived: o.pointsReceived - oldPoints[winner])
                        } else {
                            return o
                        }
                    }
                    var winLoss = pS.winLoss
                    if newWinner == winner {
                        winLoss.remove(at: winLoss.count - 1)
                    } else {
                        winLoss.remove(at: winLoss.count - 2)
                        winLoss.remove(at: winLoss.count - 1)
                        winLoss.append(winLoss.last! + 1)
                    }
                    return PlayerStats(player: pS.player, oponents: oponents, winLoss: winLoss, matchIds: pS.matchIds)
                } else {
                    return pS
                }
            }
            self.numberOfPlayedMatches -= 1
        }
        return success
    }
    
    func storePoints(matchId: UUID, points: [Int]) {
        let index = self.matches.firstIndex(where: { $0.id == matchId })!
        if self.matches[index].winner == nil {
            self.matches[index].points = points
        }
    }
    
    func deleteTournament() async {
        self.matches = []
        self.stats = []
        self.playerStats = []
        self.numberOfPlayedMatches = 0
    }
    
    func restartTournament() async {
        self.setup(rounds: self.originalRounds, players: self.players, mode: self.mode)
        self.numberOfPlayedMatches = 0
    }
    
    func sortStatsSwissEndOfRound() async {
        if self.players.count % 2 == 0 {
            for i in stride(from: 1, to: self.stats.count - 1, by: 2) {
                self.stats.swapAt(i, i + 1)
            }
        }
    }
    
    func sortStatsRoundRobin() async {
        var sortedStats = self.stats.sorted { stats1, stats2 -> Bool in
            if stats1.win > stats2.win {
                return true
            } else if stats1.win == stats2.win {
                if stats1.loss < stats2.loss {
                    return true
                } else if stats1.loss == stats2.loss {
                    // If wins are equal, sort by the difference between pointsMade and pointsReceived.
                    let diff1 = stats1.pointsMade - stats1.pointsReceived
                    let diff2 = stats2.pointsMade - stats2.pointsReceived
                    if diff1 >= diff2 {
                        return true
                    }
                }
            }
            return false
        }
        if self.playingFinals {
            for finalNumer in stride(from: 0, to: self.stats.count - 1, by: 2) {
                let finalMatch = self.matches.first(where: { $0.finalNumber == finalNumer && $0.winner != nil })
                if finalMatch != nil {
                    let winner = finalMatch!.winner!
                    let loser = (1 - winner) % 2
                    if let winnerStats = self.stats.first(where: { $0.player == finalMatch!.players[winner] }) {
                        if let loserStats = self.stats.first(where: { $0.player == finalMatch!.players[loser] }) {
                            sortedStats[finalNumer] = winnerStats
                            sortedStats[finalNumer + 1] = loserStats
                        }
                    }
                }
            }
        }
        self.stats = sortedStats
    }
    
    func getWinner() async -> String {
        if self.numberOfPlayedMatches == self.numberOfMatches {
            if self.mode == rr {
                await self.sortStatsRoundRobin()
            }
            return self.stats[0].player
        } else {
            return ""
        }
    }
    
    func tournamentStarted() -> Bool {
        return self.numberOfPlayedMatches > 0
    }
    
    func finishedWithoutFinals() {
        self.finished = true
    }
    
    func getMatchStatsForGraph(ids: [UUID], player: String) async -> [(name: String, count: Int, color: Color)]? {
        let playedMatches = self.matches.filter { ids.contains($0.id) }
        var results = [0, 0, 0, 0, 0, 0]
        for match in playedMatches {
            if match.winner != nil {
                let winner = match.winner!
                let loser = (1 - winner) % 2
                if match.players[winner] == player {
                    if match.points[loser] <= 2 {
                        results[0] += 1
                    } else if match.points[winner] - match.points[loser] <= 2 {
                        results[2] += 1
                    } else {
                        results[1] += 1
                    }
                } else {
                    if match.points[loser] <= 2 {
                        results[5] += 1
                    } else if match.points[winner] - match.points[loser] <= 2 {
                        results[3] += 1
                    } else {
                        results[4] += 1
                    }
                }
            }
        }
        if results.reduce(0, +) == 0 {
            return nil
        }
        let nameMapping: [String] = ["Clearly Won: Your opponent scored at most two points.", "Won: Your opponent scored between 2 and 8 points.", "Barely Won: Your opponent scored 2 points less than you.", "Barely Lost: You scored 2 points less than the winner.", "Lost: You scored between 2 and 8 points.", "Lost Clearly: You scored at most 2 points."]
        let colorMapping: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo]
        return results.enumerated().map { index, element in
            (name: nameMapping[index], count: element, color: colorMapping[index])
        }
    }
}
