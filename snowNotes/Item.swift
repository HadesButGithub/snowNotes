//
//  Item.swift
//  snowNotes
//
//  Created by Harry Lewandowski on 19/5/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
