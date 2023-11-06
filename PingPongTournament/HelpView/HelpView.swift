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
            Spacer()
            VStack { Image(systemName: "questionmark.circle").resizable().frame(width: 50, height: 50)

                Text("Help").font(.title2).fontWeight(.semibold)
            }
            Text("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.").font(.body).padding()
            Spacer()
        }
        .padding()
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(isShowingHelpView: .constant(false))
    }
}
