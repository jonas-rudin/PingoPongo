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
    @State var players: [String] = []

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Spacer()
                NavigationLink(destination: StartView(players: $players)) { Text("Start").bold().frame(width: 180, height: 50).background(Color.blue).foregroundColor(Color.white).cornerRadius(10) }.padding([.vertical], 6)

                Button { helpViewModel.helpIsShowing = true } label: { Text("Help").bold().frame(width: 180, height: 50).background(Color.blue).foregroundColor(Color.white).cornerRadius(10)
                }.padding([.vertical], 6)   
                
                Toggle("Dark Mode", isOn: $isDarkMode).toggleStyle(SwitchToggleStyle(tint: Color.blue)).padding()
                Spacer()
            }.padding(100).sheet(isPresented: $helpViewModel.helpIsShowing) {
                HelpView(isShowingHelpView: $helpViewModel.helpIsShowing)
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
