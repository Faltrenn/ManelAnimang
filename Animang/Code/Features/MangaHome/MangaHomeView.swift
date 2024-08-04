//
//  MangaHomeView.swift
//  Animang
//
//  Created by Emanuel on 03/08/24.
//

import SwiftUI
import SwiftSoup

struct MangaHomeView: View {
    @State var links = [
        "https://lermangas.me/manga/solo-leveling/",
        "https://lermangas.me/manga/eu-pertenco-a-familia-castielo/",
        "https://lermangas.me/manga/uma-princesa-que-le-a-sorte/",
        "https://lermangas.me/manga/reencarnando-como-o-herdeiro-louco/",
        "https://lermangas.me/manga/acima-de-todos-os-deuses/"
    ]
    
    @ObservedObject var mangaHomeVM = MangaHomeViewModel()
    
    var body: some View {
        VStack {
            Button("Adicionar") {
                if !links.isEmpty {
                    mangaHomeVM.addManga(link: links.removeFirst())
                }
            }
            ScrollView {
                VStack {
                    ForEach(mangaHomeVM.mangas, id: \.link) { manga in
                        VStack {
                            NavigationLink {
                                MangaView(mangaLink: manga.link)
                            } label: {
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
}
