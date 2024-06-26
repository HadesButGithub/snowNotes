//
//  ContentView.swift
//  snowNotes
//
//  Created by Harry Lewandowski on 19/5/2024.
//
// Why was the JavaScript developer sad?
// Because he didn't know how to ﻿null his emotions.

// Imports necessary native and Apple-developed libraries for proper functionality
import SwiftUI // Library for UI design with code, new generation of standards for building native iOS apps
import SwiftData // Library for simple data management with SwiftUI code, new gen of standard for storing data in SwiftUI apps
import TipKit // Library for displaying hints within SwiftUI apps

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
    
    var body: some View { // Defines all UI displayed on screen, standard Swift code
        var noteCount = items.count // Sets noteCount to the number of notes in the array items
        var noteCountTitle: String { // Generates string to return note or notes based on if there is 1 or more notes in the array
            if noteCount == 1 { // Checks if noteCount is 1
                return "note" // Sets string to "note" if one note is in the array
            } else {
                return "notes" // Sets string to "notes" if more than one note is in the array
            }
        }
        
        NavigationSplitView { // View that allows for navigation between Views
            Text("snowNotes") // UI definition for "snowNotes" heading
                .fontWeight(.bold) // Text properties and formatting
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.expanded)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(noteCount) \(noteCountTitle)") // Displays number of notes
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.standard)
                .fontDesign(.monospaced)
                .foregroundColor(.gray)
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
                    Button(action: addItem) { // Toolbar button that runs addItem function
                        Label("Add Item", systemImage: "plus") // UI design for button
                    }
                }
                ToolbarItem {
                    Button(action: {
                        showSettings.toggle() // Toggles the showSettings variable, which displays the settings UI page if true
                    }) {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItem {
                    EditButton() // Uses SwiftData functions to enter or exit edit mode
                }
            }
        } detail: {
            Text("Select a note.") // Adds extra text on iPad and larger screen devices when no note is actively open
        }
        .sheet(isPresented: $showSettings, content: { // Presents SettingsView() as a sheet when showSettings is true
            SettingsView()
        })
    }
    
    

    private func addItem() { // Function to add items
        withAnimation { // Ensures that an animation is played when an item is added
            let newItem = Item(timestamp: Date(), noteAccessed: Date(), noteContent: "Hello world!", noteTitle: "New Note") // Writes default variables to be added to each note when created
            modelContext.insert(newItem) // Inserts the new note into the modelContext, saving it to internal storage
        }
    }

    private func deleteItems(offsets: IndexSet) { // Deletes item
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index]) // Deletes the selected item from the modelContext
            }
        }
    }
}

struct SettingsView: View { // Displays the settings and debug view
    @Environment(\.modelContext) private var modelContext // Loads the modelContext, allowing debug features to modify it
    @State private var displayDebugAlert = false // var that, when true, displays an alert
    @State private var alertTitle = "Alert Title" // Variables to modify alert text based on different debug functions
    @State private var alertMessage = "Alert Message"
    @State private var debugQuanitityNoteCount = "0" // Number of notes that are created when using the Create Multiple Debug Notes function
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings and Debug Features")
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .padding(.top, 30.0)
                    .padding(.leading, 15.0)
                    .fontWidth(.expanded)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Create Multiple Debug Notes")
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15.0)
                    .fontWeight(.bold)
                
                TextField(text: $debugQuanitityNoteCount, label: { // Creates a text box allowing the user to enter a number of notes to create
                    Text("Debug: Create Multiple Notes")
                }) 
                .keyboardType(.numberPad) // Ensures the user can only enter numbers, one of two protections ensuring the string can correctly convert to an integer, as text fields can only use String variables
                .padding(.leading, 15.0)
                .padding(.trailing, 15.0)
                .textFieldStyle(.roundedBorder)
                
                Button("Create Notes") { // Button that runs the debug function
                    debugCreateQuantityNotes()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 5.0)
                Spacer()

                Button(action: { // Button that deletes all notes
                    resetAllData()
                }) {
                    Text("Reset All Data")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
                Spacer()
            }
        }.alert(isPresented: $displayDebugAlert) { // Waits for displayDebugAlert to become true, and displays an alert when it occurs.
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"))) // Presents alert using variable text
        }
    }
    
    func debugCreateQuantityNotes() { // Function to create multiple notes
        var notesCreated = 1 // Sets notesCreated to 1
        var noteQtyInt: Int { // Converts debugQuantityNoteCount to an integer and sets it to noteQtyInt
            Int(debugQuanitityNoteCount) ?? 0 // Uses Swift functionality to validate that the var can be successfully converted to an integer, and sets the Int to 0 if an error occurs. Second measure of protection.
        }
        
        while notesCreated <= noteQtyInt { // Runs while loop while the amount of notes created is less than or equal to the amount of notes the user enters
            let newItem = Item(timestamp: Date(), noteAccessed: Date(), noteContent: "Hello world!", noteTitle: "Debug Note \(notesCreated)")
            modelContext.insert(newItem) // Creates a new item in the modelContext
            notesCreated += 1 // Adds one to notesCreated
        }
        alertTitle = "Created Notes" // Sets alert variables to display an alert once the operation has completed
        alertMessage = "\(noteQtyInt) notes have been created."
        displayDebugAlert = true // Displays alert
        notesCreated = 0 // Resets notesCreated to 0
    }
    
    func resetAllData() {
        do {
            try modelContext.delete(model: Item.self) // Deletes everything from the modelContext
            alertTitle = "Deleted All Notes" // Sets alert variables
            alertMessage = "All notes have been deleted. Quit the app from the App Switcher to apply changes."
            displayDebugAlert = true // Displays alert
        } catch {
            print("Failed to delete notes.") // Prints error to console if operation fails
        }
    }
    
}

struct EditNoteView: View {
    @ObservedObject var viewModel: NoteViewModel // Loads model for each item to open all contents of a single item
    var editTitleTip = EditTitleTip() // Loads the hint defined earlier in code
    var shouldResetTips = false // Resets the tips when set to true, allowing the app to display the hint an infinite number of times. Used for UI design and debugging.
    
    var body: some View {
        VStack {
            TextField("Title", text: $viewModel.item.noteTitle) // Sets the title text field to noteTitle from the item
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.standard)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .popoverTip(editTitleTip) // Displays the hint for editing a title
                .onTapGesture {
                    editTitleTip.invalidate(reason: .actionPerformed) // Permanently invalidates the hint once the hint is closed or the title is tapped
                }
            
            Text("Created at \(viewModel.item.timestamp, format: .dateTime)") // Displays creation time from item viewModel
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.standard)
                .font(.footnote)
                .fontDesign(.monospaced)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Last modified at \(viewModel.item.noteAccessed, format: .dateTime)") // Displays modification time from item viewModel
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.standard)
                .font(.footnote)
                .fontDesign(.monospaced)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $viewModel.item.noteContent) // Displays contents of the note as an editor
                .multilineTextAlignment(.leading)
                .padding(.leading, 10.0)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task {
            if shouldResetTips == true {
                try? Tips.resetDatastore() // Resets the Tips Datastore if shouldResetTips is set to true
            }
        
            try? Tips.configure([ // Configuration option for tips
                .displayFrequency(.immediate), // Displays the hint immediately
                .datastoreLocation(.applicationDefault) // Uses default storage location for configuration
            ])
        }
        .onChange(of: viewModel.item.noteTitle) { _ in // Saves the new title if it is modified
            viewModel.item.noteAccessed = Date()
            viewModel.save()
        }
        .onChange(of: viewModel.item.noteContent) { _ in // Saves note content if modified
            viewModel.item.noteAccessed = Date()
            viewModel.save()
        }
        
        // Save functions separated to ensure note or title isn't resaved unnecessarily if one or the other isn't edited.
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true) // Preview configuration options for Xcode canvas
}

// finally done
// i can uninstall xcode and get like 50GB of storage back 🤩
