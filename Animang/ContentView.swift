//
//  ContentView.swift
//  Manganel&Animes
//
//  Created by Emanuel on 13/03/24.
//

import SwiftUI

struct ContentView: View {
    @State var page: TabbedPages = .manga
    
    var body: some View {
        ZStack(alignment: .bottom){
            ZStack {
                switch page {
                case .manga:
                    MangaHomeView()
                case .anime:
                    Text("Anime")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                ForEach(TabbedPages.allCases, id: \.self) { p in
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
