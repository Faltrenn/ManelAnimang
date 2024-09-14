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
                
                List { 
                    ForEach(animeHVM.animes, id: \.link) { anime in
                        ZStack {
                            NavigationLink(destination: AnimeView(anime: anime, selector: .megaflix)) {
                                EmptyView()
                            }.opacity(0.0)
                            AnimeCard(anime: anime)
                                .swipeActions(edge: .leading) {
                                    Button("Remover", systemImage: "trash") {
                                        animeHVM.removeAnime(anime: anime)
                                    }
                                    .tint(.red)
                                }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .environmentObject(animeHVM)
    }
}

#Preview {
    AnimeHomeView()
}
