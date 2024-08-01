//
//  ContentView.swift
//  Manganel&Animes
//
//  Created by Emanuel on 13/03/24.
//

import SwiftUI

enum Pages: CaseIterable {
    case manga, anime
    
    var title: String {
        switch self {
        case .manga:
            "Manga"
        case .anime:
            "Anime"
        }
    }
}

struct ContentView: View {
    @State var page: Pages = .manga
    
    var body: some View {
        ZStack(alignment: .bottom){
            ZStack {
                switch page {
                case .manga:
                    ChapterView()
                case .anime:
                    Text("Anime")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                ForEach(Pages.allCases, id: \.self) { p in
                    Button {
                        page = p
                    } label: {
                        Text(p.title)
                    }
                }
            }
        }
        .padding()
        .ignoresSafeArea(edges: [.bottom])
    }
}

#Preview {
    ContentView()
}
