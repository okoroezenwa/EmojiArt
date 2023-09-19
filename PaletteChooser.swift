//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Ezenwa Okoro on 18/09/2023.
//

import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var store: PaletteStore
    @State private var showPaletteEditor = false
    @State private var showPaletteList = false
    
    var body: some View {
        HStack {
            chooser
            
            view(for: store.palettes[store.cursorIndex])
        }
        .clipped()
        .sheet(isPresented: $showPaletteEditor) {
            PaletteEditor(palette: $store.palettes[store.cursorIndex])
                .font(nil)
        }
        .sheet(isPresented: $showPaletteList) {
            NavigationStack {
                EditablePaletteList(store: store)
                    .font(nil)
            }
        }
    }
    
    private var chooser: some View {
        AnimatedActionButton(systemImage: "paintpalette") {
            store.cursorIndex += 1
        }
        .contextMenu {
            goToMenu
            
            AnimatedActionButton("New", systemImage: "plus") {
                store.insert(name: "Math", emojis: "+−×÷∞")
            }
            
            AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) {
                store.palettes.remove(at: store.cursorIndex)
            }
            
            AnimatedActionButton("Edit", systemImage: "pencil") {
                showPaletteEditor = true
            }
            
            AnimatedActionButton("List", systemImage: "list.bullet.rectangle.portrait") {
                showPaletteList = true
            }
        }
    }
    
    private var goToMenu: some View {
        Menu {
            ForEach(store.palettes) { palette in
                AnimatedActionButton(palette.name) {
                    if let index = store.palettes.firstIndex(where: { $0.id == palette.id }) {
                        store.cursorIndex = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojis(palette.emojis)
        }
        .id(palette.id)
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
    }
}

#Preview {
    PaletteChooser()
        .environmentObject(PaletteStore(named: "Preview"))
}

struct ScrollingEmojis: View {
    let emojis: [String]
    
    init(_ emojis: String) {
        self.emojis = emojis.uniqued.map(String.init)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
        }
    }
}

