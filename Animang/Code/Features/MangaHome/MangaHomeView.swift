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
                .font(.title2)
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
                    NamerTag("Nome alternativo", manga.altName)
                    NamerTag("Gêneros", manga.genres)
                    NamerTag("Último capítulo", manga.lastChapter)
                    NamerTag("Status", manga.status)
                    NamerTag("Lançamento", manga.launch)
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
