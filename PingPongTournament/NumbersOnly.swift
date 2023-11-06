//
//  NumbersOnly.swift
//  PingPongTournament
//
//  Created by J. Rudin on 06.10.23.
//

import Foundation

class NumbersSmaller10Only: ObservableObject {
    @Published var value = "1" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
            if Int(value) ?? 0 > 10 {
                value = "10"
            }
            if Int(value) ?? 1 == 0 || value == "" {
                value = "1"
            }
        }
    }
}
