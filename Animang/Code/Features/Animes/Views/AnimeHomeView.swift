//
//  AnimeHomeView.swift
//  Animang
//
//  Created by Emanuel on 12/08/24.
//

import SwiftUI

struct AnimeHomeView: View {
    @ObservedObject var animeHVM = AnimeHomeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    SearchMediaView<AnimeHomeViewModel>(selector: .megaflix)
                } label: {
                    Text("Adicionar")
                }
                
//                List {
//                    ForEach(mangaHomeVM.mangas, id: \.link) { manga in
//                        ZStack {
//                            NavigationLink(destination: MangaView(manga: manga, mangaSelector: .leitorDeManga)) {
//                                EmptyView()
//                            }.opacity(0.0)
//                            MangaCard(manga: manga)
//                                .swipeActions(edge: .leading) {
//                                    Button("Remover", systemImage: "trash") {
//                                        mangaHomeVM.removeManga(manga: manga)
//                                    }
//                                    .tint(.red)
//                                }
//                        }
//                        .listRowSeparator(.hidden)
//                    }
//                }
//                .listStyle(.plain)
            }
        }
        .environmentObject(animeHVM)
    }
}

#Preview {
    AnimeHomeView()
}
