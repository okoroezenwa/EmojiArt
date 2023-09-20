//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Ezenwa Okoro on 17/09/2023.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    typealias CGOffset = CGSize
    
    @ObservedObject var document: EmojiArtDocument
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    @StateObject var paletteStore = PaletteStore(named: "Shared")
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    @State private var showBackgroundFailureAlert = false
    @ScaledMetric private var paletteEmojiSize: CGFloat = 40
    @Environment(\.undoManager) var undoManager
    private let emojis = "👻🍎😃🤪☹️🤯🐶🐭🦁🐵🦆🐝🐢🐄🐖🌲🌴🌵🍄🌞🌎🔥🌈🌧️🌨️☁️⛄️⛳️🚗🚙🚓🚲🛺🏍️🚘✈️🛩️🚀🚁🏰🏠❤️💤⛵️"
    
    var body: some View {
        VStack {
            documentBody
            
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
        .toolbar {
            UndoButton()
        }
        .environmentObject(paletteStore)
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom *= inMotionPinchScale
            }
            .onEnded { endingPinchScale in
                zoom *= endingPinchScale
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { value, gesturePan, _ in
                gesturePan = value.translation
            }
            .onEnded { value in
                pan += value.translation
            }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                
                if document.background.isFetching {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.blue)
                        .position(Emoji.Position.zero.in(geometry))
                }
                
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(
                panGesture.simultaneously(with: zoomGesture)
            )
            .onTapGesture(count: 2) {
                zoomToFit(document.bbox, in: geometry)
            }
            .dropDestination(for: Sturldata.self) { sturldata, location in
                return drop(sturldata, at: location, in: geometry)
            }
            .onChange(of: document.background.failureReason) { reason in
                showBackgroundFailureAlert = reason != nil
            }
            .onChange(of: document.background.uiImage) { uiImage in
                zoomToFit(uiImage?.size, in: geometry)
            }
            .alert(
                "Set Background",
                isPresented: $showBackgroundFailureAlert,
                presenting: document.background.failureReason,
                actions: { reason in
                    Button("OK", role: .cancel) { }
                },
                message: { reason in
                    Text(reason)
                }
            )
        }
    }
    
    private func zoomToFit(_ size: CGSize?, in geometry: GeometryProxy) {
        if let size {
            zoomToFit(CGRect(center: .zero, size: size), in: geometry)
        }
    }
    
    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
        withAnimation {
            if rect.size.width > 0, rect.size.height > 0,
               geometry.size.width > 0, geometry.size.height > 0 {
                let hZoom = geometry.size.width / rect.size.width
                let vZoom = geometry.size.height / rect.size.height
                zoom = min(hZoom, vZoom)
                pan = CGOffset(
                    width: -rect.midX * zoom,
                    height: -rect.midY * zoom
                )
            }
        }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        if let uiImage = document.background.uiImage {
            Image(uiImage: uiImage)
                .position(Emoji.Position.zero.in(geometry))
        }
        
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .font(emoji.font)
                .position(emoji.position.in(geometry))
        }
    }
    
    private func drop(_ sturldata: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldata {
            switch sturldata {
                case .url(let url):
                    document.setBackground(url, undoWith: undoManager)
                case .string(let emoji):
                    document.addEmoji(
                        emoji,
                        at: emojiPosition(at: location, in: geometry),
                        size: paletteEmojiSize / zoom,
                        undoWith: undoManager
                    )
                default:
                    break
            }
            return true
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
}

#Preview {
    EmojiArtDocumentView(
        document: EmojiArtDocument()
    )
    .environmentObject(PaletteStore(named: "Preview"))
}
