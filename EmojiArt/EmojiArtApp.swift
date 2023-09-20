//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Ezenwa Okoro on 17/09/2023.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var defaultDocument = EmojiArtDocument()
    
    var body: some Scene {
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            EmojiArtDocumentView(document: config.document)
        }
    }
}
