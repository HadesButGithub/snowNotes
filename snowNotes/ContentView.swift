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
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var editTitleTip = EditTitleTip()
    var shouldResetTips = true

    var body: some View {
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
                            Text(item.noteTitle)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .overlay(content: {
                if items.isEmpty {
                    Text("Click the + to create a new note.")
                        .foregroundColor(Color.gray)
                }
            })
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date(), noteContent: "Hello world!", noteTitle: "New Note")
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

struct EditNoteView: View {
    @ObservedObject var viewModel: NoteViewModel

    var body: some View {
        VStack {
            TextField("Placeholder", text: $viewModel.item.noteTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .padding(.leading, 15.0)
                .fontWidth(.standard)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .popoverTip(EditTitleTip())

            TextEditor(text: $viewModel.item.noteContent)
                .multilineTextAlignment(.leading)
                .padding(.leading, 10.0)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: viewModel.item.noteTitle) { _ in
            viewModel.save()
        }
        .onChange(of: viewModel.item.noteContent) { _ in
            viewModel.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
