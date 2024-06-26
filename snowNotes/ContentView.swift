//
//  ContentView.swift
//  snowNotes
//
//  Created by Harry Lewandowski on 19/5/2024.
//
// Why was the JavaScript developer sad?
// Because he didn't know how to ﻿null his emotions.

import SwiftUI
import SwiftData
import TipKit

// Defines storage model for notes
class NoteViewModel: ObservableObject {
    @Published var item: Item
    @Environment(\.managedObjectContext) private var managedObjectContext

    init(item: Item) {
        self.item = item // initiates data type item as itself
    }

    func save() { // Called to save content to internal storage
        do {
            try managedObjectContext.save() // attempts to save
        } catch {
            print("Error saving note: \(error)") // prints error if unable to save
        }
    }
}

struct EditTitleTip: Tip { // Defines hint displayed on first launch
    var title: Text {
        Text("Create a Title") // Title of hint
    }
    
    var message: Text? {
        Text("Tap on the title of your note to change it.") // Message displayed in hint
    }
    
    var image: Image? {
        Image(systemName: "pencil.line") // Image used within hint defined from SF Symbols
    }
    
    var options: [Option] {
           MaxDisplayCount(1) // Restricts the hint to display once
       }
}

struct EditTextTip: Tip { // Defines hint on how to edit a note, unused
    var title: Text {
        Text("Write a Note")
    }
    
    var message: Text? {
        Text("Tap inside the text box to edit your note.")
    }
    
    var image: Image? {
        Image(systemName: "note.text")
    }
}

struct ContentView: View { // Defines main UI view
    @Environment(\.modelContext) private var modelContext // Loads stored notes into memory
    @Query private var items: [Item] // Sets var items into an array of the notes stored in the modelContext
    @State private var showSettings = false // Defines whether Settings sheet appears
    
    var body: some View {
        NavigationSplitView { // View that allows for navigation between Views
            Text("snowNotes") // UI definition for "snowNotes" heading
                .fontWeight(.bold) // Text properties
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.expanded)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)

            List { // Lists all notes in context
                ForEach(items) { item in // Creates item in List for each item in modelContext
                    NavigationLink(destination: EditNoteView(viewModel: NoteViewModel(item: item))) { // Opens EditNoteView with values of the selected item from modelContext
                        VStack(alignment: .leading){ // Defines UI for each item in List
                            Text(item.noteTitle) // Adds title to items
                            Text("Last modified \(item.noteAccessed, format: .dateTime)") // Adds date the note was last changed
                                .fontDesign(.monospaced)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteItems) // Runs deleteItems function if item is deleted
            }
            .scrollContentBackground(.visible)
            .overlay(content: { // Defines UI shown if no notes exist
                if items.isEmpty {
                    Text("Click the + to create a new note.") // Text and text formatting
                        .foregroundColor(Color.gray)
                }
            })
            .toolbar { // Defines buttons shown in toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItem {
                    EditButton()
                }
            }
        } detail: {
            Text("Select a note.")
        }
        .sheet(isPresented: $showSettings, content: {
            SettingsView()
        })
    }
    
    

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date(), noteAccessed: Date(), noteContent: "Hello world!", noteTitle: "New Note")
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .padding(.top, 30.0)
                    .padding(.leading, 15.0)
                    .fontWidth(.expanded)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Settings")
                    .font(.title)
                Spacer()
                Text("hello world!")
            }
        }
    }
}

struct EditNoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    var editTitleTip = EditTitleTip()
    var editTextTip = EditTextTip()
    var shouldResetTips = false
    
    var body: some View {
        VStack {
            TextField("Title", text: $viewModel.item.noteTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.standard)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .popoverTip(editTitleTip)
                .onTapGesture {
                    editTitleTip.invalidate(reason: .actionPerformed)
                }
            
            Text("Created at \(viewModel.item.timestamp, format: .dateTime)")
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.standard)
                .font(.footnote)
                .fontDesign(.monospaced)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Last modified at \(viewModel.item.noteAccessed, format: .dateTime)")
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.standard)
                .font(.footnote)
                .fontDesign(.monospaced)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $viewModel.item.noteContent)
                .multilineTextAlignment(.leading)
                .padding(.leading, 10.0)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task {
            if shouldResetTips == true {
                try? Tips.resetDatastore()
            }
        
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
        .onChange(of: viewModel.item.noteTitle) { _ in
            viewModel.item.noteAccessed = Date()
            viewModel.save()
        }
        .onChange(of: viewModel.item.noteContent) { _ in
            viewModel.item.noteAccessed = Date()
            viewModel.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
