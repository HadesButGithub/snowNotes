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
    var noteAccessed: Date
    var noteContent: String
    var noteTitle: String
    
    init(timestamp: Date, noteAccessed: Date, noteContent: String, noteTitle: String) {
        self.timestamp = timestamp
        self.noteAccessed = noteAccessed
        self.noteContent = noteContent
        self.noteTitle = noteTitle
    }
}
