//
//  PingPongTournamentApp.swift
//  PingPongTournament
//
//  Created by J. Rudin on 06.10.23.
//

import SwiftUI

@main
struct PingPongTournamentApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("scrollResult") private var scrollResult = true

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
