//
//  MenuView.swift
//  PingPongTournament
//
//  Created by J. Rudin on 06.10.23.
//

import SwiftUI

struct MenuView: View {
    @StateObject var helpViewModel = HelpViewModel()
    @AppStorage("isDarkMode") var isDarkMode: Bool = true

    var body: some View {
        NavigationView {
            ZStack {
//                LinearGradient(gradient: Gradient(colors: [.mint, .white]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                VStack(alignment: .center) {
                    NavigationLink(destination: StartView()) { Text("Start").bold().frame(width: 180, height: 50).background(Color.blue).foregroundColor(Color.white).cornerRadius(10) }

                    Button { helpViewModel.helpIsShowing = true } label: { Text("Help").bold().frame(width: 180, height: 50).background(Color.blue).foregroundColor(Color.white).cornerRadius(10)
                    }

                    Toggle("Dark Mode", isOn: $isDarkMode).toggleStyle(SwitchToggleStyle(tint: Color.blue)).padding()

                }.padding(100).sheet(isPresented: $helpViewModel.helpIsShowing) {
                    HelpView(isShowingHelpView: $helpViewModel.helpIsShowing)
                }
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
