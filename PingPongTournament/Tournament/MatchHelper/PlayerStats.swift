//
//  PlayerStats.swift
//  PingPongTournament
//
//  Created by J. Rudin on 21.10.2023.
//

import Foundation

struct Stats: Hashable, Identifiable {
    let id = UUID()
    var player: String
    var win: Int = 0
    var loss: Int = 0
    var pointsMade: Int = 0
    var pointsReceived: Int = 0
}

struct PlayerStats: Hashable, Identifiable {
    let id = UUID()
    var player: String
    var oponents: [OponentStats]
    var winLoss: [Int] = [0]
    var matchIds: [UUID] = []
}

struct OponentStats: Hashable, Identifiable {
    let id = UUID()
    var player: String
    var win: Int = 0
    var loss: Int = 0
    var pointsMade: Int = 0
    var pointsReceived: Int = 0
}
