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
    
    init(_ title: String, _ value: String) {
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
                        NavigationLink {
                            MangaView(mangaLink: manga.link)
                        } label: {
                            MangaCard(manga: manga)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            mangaHomeVM.addManga(link: "https://lermangas.me/manga/a-monster-hunter-becomes-a-princess/")
        }
    }
}

#Preview {
    NavigationStack {
        MangaHomeView()
    }
    .tint(.primary)
    .environmentObject(MangaHomeViewModel())
}
