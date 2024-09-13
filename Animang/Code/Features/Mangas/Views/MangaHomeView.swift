//
//  MangaHomeView.swift
//  Animang
//
//  Created by Emanuel on 03/08/24.
//

import SwiftUI
import SwiftSoup

struct NamerTag: View {
    let title: String
    let value: String
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
            Text(value)
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MangaCard: View {
    @ObservedObject var manga: Manga
    
    var body: some View {
        VStack {
            Text(manga.title)
                .font(.title2)
                .bold()
            HStack(alignment: .top) {
                VStack {
                    AsyncImage(url: URL(string: manga.imageLink)) { image in 
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 216)
                    } placeholder: {
                        ProgressView()
                    }
                }
                VStack(alignment: .leading) {
//                    NamerTag("Nome alternativo", manga.altName)
//                    NamerTag("Gêneros", manga.genres)
//                    NamerTag("Último capítulo", manga.lastChapter)
//                    NamerTag("Status", manga.status)
//                    NamerTag("Lançamento", manga.launch)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(10)
                .font(.subheadline)
                .background(Color(red: 21/255, green: 22/255, blue: 29/255))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .multilineTextAlignment(.leading)
            }
        }
    }
}

struct MangaHomeView: View {
    @ObservedObject var mangaHomeVM = MangaHomeViewModel()
     
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    SearchMediaView<MangaHomeViewModel>(selector: .leitorDeManga)
                } label: { 
                    Text("Adicionar")
                }
                
                List {
                    ForEach(mangaHomeVM.mangas, id: \.link) { manga in
                        ZStack {
                            NavigationLink(destination: MangaView(manga: manga, mangaSelector: .leitorDeManga)) {
                                EmptyView()
                            }.opacity(0.0)
                            MangaCard(manga: manga)
                                .swipeActions(edge: .leading) {
                                    Button("Remover", systemImage: "trash") {
                                        mangaHomeVM.removeManga(manga: manga)
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
        .environmentObject(mangaHomeVM)
    }
}

#Preview {
    MangaHomeView()
}
