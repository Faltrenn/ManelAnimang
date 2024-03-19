//
//  MangaView.swift
//  Animang
//
//  Created by Emanuel on 18/03/24.
//

import SwiftUI

struct MangaHomeView: View {
    @ObservedObject var mangaVM = MangaViewModel()
    
    let columns = [
        GridItem(.flexible(minimum: 50)),
        GridItem(.flexible(minimum: 50)),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(mangaVM.mangas, id: \.self) { manga in
                        NavigationLink {
                            Text("MangaView")
                        } label: {
                            MangaCardView(manga: manga)
                        }
                    }
                }
            }
        }
        .onAppear {
            mangaVM.addManga(link: "https://lermanga.org/mangas/solo-leveling/")
        }
    }
}

#Preview {
    ContentView()
}
