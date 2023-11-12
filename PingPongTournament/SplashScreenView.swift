//
//  SplashScreenView.swift
//  PingPongTournament
//
//  Created by J. Rudin on 06.10.23.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var body: some View {
        if isActive {
            MenuView().preferredColorScheme(isDarkMode ? .dark : .light)

        } else {
            VStack {
                VStack {
                    if isDarkMode {
                        Image(.introdark).resizable().frame(width: 200, height: 200).foregroundColor(.black.opacity(0.80))
                    }
                    else {
                        Image(.intro).resizable().frame(width: 200, height: 200).foregroundColor(.black.opacity(0.80))
                    }
                    Text("Pingo Pongo").font(.title).bold()
                }
                .padding()
                .scaleEffect(size).opacity(opacity).onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1
                    }
                }
                .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { self.isActive = true }
                    }
                }
               
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
