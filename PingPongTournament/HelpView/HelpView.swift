//
//  HelpView.swift
//  PingPongTournament
//
//  Created by J. Rudin on 06.10.23.
//

import SwiftUI

struct HelpView: View {
    @Binding var isShowingHelpView: Bool
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button { isShowingHelpView = false } label: { Image(systemName: "xmark").foregroundColor(Color(.label)).imageScale(.medium).frame(width: 44, height: 44)
                }.padding()
            }
            NavigationView {
                TabView {
                    RulesView().tabItem {
                        Image(systemName: "questionmark.circle")
                        Text("Rules").bold()
                    }
                    ModesView().tabItem {
                        Image(systemName: "arrow.down.forward.and.arrow.up.backward.circle")
                        Text("Modes").bold()
                    }
                }
            }
        }
    }
}

struct RulesView: View {
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                VStack { Image(systemName: "questionmark.circle").resizable().frame(width: 50, height: 50)

                    Text("Rules").font(.title2).fontWeight(.bold)
                }
                Text("")
                Text("")
                Text("Welcome to the ")+Text("PingoPongo").bold()+Text(" Table Tennis Tournament App, your ultimate tool for managing and enjoying table tennis tournaments in a round robin or swiss system format. Here's an overview of the app's layout and functionalities:")
                Text("1. Tournament Setup:").font(.title2).fontWeight(.semibold).padding()
                Text("Start by creating a new tournament. Specify the tournament mode and if you choose the round robin format, the initial number of rounds you plan to play. Add players to your tournament by entering their names and relevant details. You can also sort the players by drag and drop which is useful when playing the swiss system. Sorte them, starting with the best player.")
                Text("2. Rounds:").font(.title2).fontWeight(.semibold).padding()
                Text("The app allows you to manage the tournament rounds effortlessly.Initially, define the number of rounds to be played. If needed, additional rounds can be added during the tournament, providing flexibility.")
                Text("3. Match Rules:").font(.title2).fontWeight(.semibold).padding()
                Text("Matches are played until one player reaches 11 points, and if the score is higher, a difference of two points is required. Each round features every player playing against every other player.")
                Text("4. Tournament Progress:").font(.title2).fontWeight(.semibold).padding()
                Text("In the ")+Text(Image(systemName: "figure.table.tennis"))+Text(" Open").bold()+Text(" tab, you can view and enter scores for matches that need to be played. In the ")+Text(Image(systemName: "list.clipboard"))+Text(" Played").bold()+Text(" tab, you can review and edit scores for matches that have already taken place, excluding the finals.")
                Text("5. Finals:").font(.title2).fontWeight(.semibold).padding()
                Text("Once all rounds are played, you have the option to add additional rounds or proceed to the finals. The finals feature players with the most wins or points, with first playing against second, third against fourth, and so on. If there's an uneven number of players, the last player does not participate in the finals.")
                Text("6. Final Match Rules:").font(.title2).fontWeight(.semibold).padding()
                Text("In the finals, matches can be played to 11 or 21 points, or if higher with the required two-point difference.")
                Text("7. Stats and Results:").font(.title2).bold().padding()
                Text("The ")+Text(Image(systemName: "medal"))+Text(" Stats").bold()+Text(" tab displays the statistics of players, including who is currently leading and who has won the most matches. Clicking on a player's name provides additional insights into their performance. ")
                Spacer()
                Text("")
                Divider().frame(width: 100, height: 4)
                Text("")
                Spacer()
                Text("Enjoy your table tennis tournament, and may the best player win! Good luck and have fun!")

                Spacer()
            }
        }
        .padding()
    }
}

struct ModesView: View {
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                VStack { Image(systemName: "arrow.down.forward.and.arrow.up.backward.circle").resizable().frame(width: 50, height: 50)

                    Text("Modes").font(.title2).fontWeight(.bold)
                }
                Text("")
                Text("")
                Text("Round Robin").font(.title2).fontWeight(.semibold).padding()
                Text("In the Round Robin format, in each round every participant plays against every other participant in the tournament.")
                Text("Swiss System").font(.title2).fontWeight(.semibold).padding()
                Text("In the Swiss system format in each round participants are paired based on their last performance rather than a fixed schedule. Players with similar skills face each other in each round, providing a balanced competition. This format is suitable for a tournament with more than 10 paritcipants. If the number of participants is odd, the best and worst-ranked players take turns skipping a round.")
                Spacer()
            }
        }
        .padding()
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(isShowingHelpView: .constant(false))
    }
}
