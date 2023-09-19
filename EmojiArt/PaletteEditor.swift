//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Ezenwa Okoro on 18/09/2023.
//

import SwiftUI

struct PaletteEditor: View {
    enum Focused {
        case name
        case addEmojis
    }
    
    @Binding var palette: Palette
    @State private var emojisToAdd: String = ""
    @FocusState private var focused: Focused?
    
    private let emojiFont = Font.system(size: 40)
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $palette.name)
                    .focused($focused, equals: .name)
            } header: {
                Text("Name")
            }
            
            Section {
                TextField("Add Emojis Here", text: $emojisToAdd)
                    .focused($focused, equals: .addEmojis)
                    .font(emojiFont)
                    .onChange(of: emojisToAdd) { emojisToAdd in
                        palette.emojis = (emojisToAdd + palette.emojis)
                            .filter { $0.isEmoji }
                            .uniqued
                    }
                
                removeEmojis
            } header: {
                Text("Emojis")
            }
        }
        .frame(minWidth: 300, minHeight: 350)
        .onAppear {
            if palette.name.isEmpty {
                focused = .name
            } else {
                focused = .addEmojis
            }
        }
    }
    
    var removeEmojis: some View {
        VStack(alignment: .trailing) {
            Text("Tap to Remove Emojis")
                .font(.caption)
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.remove(emoji.first!)
                                emojisToAdd.remove(emoji.first!)
                            }
                        }
                }
            }
        }
        .font(emojiFont)
    }
}

//#Preview {
//    PaletteEditor()
//}
