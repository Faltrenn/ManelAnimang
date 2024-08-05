//
//  MangaHomeView.swift
//  Animang
//
//  Created by Emanuel on 03/08/24.
//

import SwiftUI
import SwiftSoup

struct MangaCard: View {
    let manga: Manga
    
    var body: some View {
        VStack {
            Text(manga.name)
            Text(manga.altName)
            Text(manga.genres)
            Text(manga.lastChapter)
            Text(manga.launch)
            Text(manga.status)
            Text(manga.score)
            AsyncImage(url: URL(string: manga.imageLink)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
        }
    }
}

struct MangaHomeView: View {
    @State var links = [
        "https://lermangas.me/manga/solo-leveling/",
        "https://lermangas.me/manga/eu-pertenco-a-familia-castielo/",
        "https://lermangas.me/manga/uma-princesa-que-le-a-sorte/",
        "https://lermangas.me/manga/reencarnando-como-o-herdeiro-louco/",
        "https://lermangas.me/manga/acima-de-todos-os-deuses/"
    ]
    
    @EnvironmentObject var mangaHomeVM: MangaHomeViewModel
    
    var body: some View {
        VStack {
            NavigationLink {
                MangaSearchView()
            } label: {
                Text("Adicionar")
            }

            ScrollView {
                VStack {
                    ForEach(mangaHomeVM.mangas, id: \.link) { manga in
                        VStack {
                            NavigationLink {
                                MangaView(mangaLink: manga.link)
                            } label: {
                                MangaCard(manga: manga)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MangaHomeView()
    }
    .environmentObject(MangaHomeViewModel())
}
