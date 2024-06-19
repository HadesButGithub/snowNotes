//
//  ContentView.swift
//  snowNotes
//
//  Created by Harry Lewandowski on 19/5/2024.
//

import SwiftUI
import SwiftData
import TipKit

class NoteViewModel: ObservableObject {
    @Published var item: Item
    @Environment(\.managedObjectContext) private var managedObjectContext

    init(item: Item) {
        self.item = item
    }

    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving note: \(error)")
        }
    }
}

class appOptions: ObservableObject {
    @AppStorage("creationOnHome") var creationOnHome = false
}

struct EditTitleTip: Tip {
    var title: Text {
        Text("Create a Title")
    }
    
    var message: Text? {
        Text("Tap on the title of your note to change it.")
    }
    
    var image: Image? {
        Image(systemName: "pencil.line")
    }
    
    var options: [Option] {
           MaxDisplayCount(1)
       }
}

struct EditTextTip: Tip {
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

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showSettings = false
    @ObservedObject var option: appOptions = appOptions()
    
    var body: some View {
        @State var creationOnHomeCV = option.creationOnHome

        NavigationSplitView {
            Text("snowNotes")
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.expanded)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)

            List {
                ForEach(items) { item in
                    NavigationLink(destination: EditNoteView(viewModel: NoteViewModel(item: item))) {
                        VStack(alignment: .leading){
                            Text(item.noteTitle)
                            Text("Last modified \(item.noteAccessed, format: .dateTime)")
                                .fontDesign(.monospaced)
                                .font(.caption)
                                .foregroundColor(.gray)
                            if creationOnHomeCV == true {
                                Text("Last created \(item.timestamp, format: .dateTime)")
                                    .fontDesign(.monospaced)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .scrollContentBackground(.visible)
            .overlay(content: {
                if items.isEmpty {
                    Text("Click the + to create a new note.")
                        .foregroundColor(Color.gray)
                }
            })
            .toolbar {
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
    @ObservedObject var option: appOptions = appOptions()

    var body: some View {
        @State var creationOnHomeSettings = option.creationOnHome
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
                Toggle(isOn: $creationOnHomeSettings) {
                        Text("Display Creation Date on Home Screen")
                    }
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
    var shouldResetTips = true
    
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
