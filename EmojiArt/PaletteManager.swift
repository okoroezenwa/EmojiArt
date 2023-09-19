//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Ezenwa Okoro on 19/09/2023.
//

import SwiftUI

struct PaletteManager: View {
    let stores: [PaletteStore]
    
    @State private var selectedStore: PaletteStore?
    
    var body: some View {
        NavigationSplitView {
            List(stores, selection: $selectedStore) { store in
                Text(store.name)
                    .tag(store)
            }
        } content: {
            if let selectedStore {
                EditablePaletteList(store: selectedStore)
            } else {
                Text("Choose a store")
            }
        } detail: {
            Text("Choose a store")
        }
    }
}
