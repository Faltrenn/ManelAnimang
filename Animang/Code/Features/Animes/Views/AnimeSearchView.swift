//
//  AnimeSearch.swift
//  Animang
//
//  Created by Emanuel on 14/08/24.
//

import SwiftUI
import SwiftSoup

struct AnimeCard: View {
    let anime: Anime
    
    var body: some View {
        VStack {
            Text(anime.title)
                .bold()
                .multilineTextAlignment(.center)
            VStack {
                AsyncImage(url: URL(string: anime.imageLink)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        
                } placeholder: {
                    ProgressView()
                }
            }
        }
    }
}

struct AnimeSearchView: View {
    @State var searchedAnimes: [Anime] = []
    @State var search: String = "Rick"
    
    var body: some View {
        VStack {
            HStack {
                TextField("opa", text: $search)
                Button("search") {
                    searchAnime(search: search)
                }
            }
            .padding()
            Grid {
                ForEach(searchedAnimes, id: \.link) { anime in
                    GridRow {
                        AnimeCard(anime: anime)
                            .listRowSeparator(.hidden)
                    }
//                        .swipeActions(edge: .leading) {
//                            if !mangaHomeVM.hasManga(manga: manga) {
//                                Button("Adicionar", systemImage: "plus.circle.fill") {
//                                    mangaHomeVM.addManga(link: manga.link)
//                                }
//                                .tint(.green)
//                            }
//                        }
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            searchAnime(search: search)
        }
    }
    
    func searchAnime(search: String) {
        searchedAnimes = []
        if let url = URL(string: "https://www.aniture-pt.com.br/search?q=\(String(describing: search.searchFormat))") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                    do {
                        let parse = try SwiftSoup.parse(html)
                        let mangas = try parse.select("div[class=post bar hentry]")
                        for manga in mangas {
                            let animeLink = try manga.select("a").attr("href")
                            let imageLink = try manga.select("img").attr("src")
                            let name = try manga.select("h2[class=post-title entry-title]").text()
//                            DispatchQueue.main.async {
//                                self.searchedAnimes.append(Anime(name: name, animeLink: animeLink, imageLink: imageLink, description: "", episodesLinks: []))
//                            }
                        }
                    } catch {
                        print("ERROR: ", error)
                    }
                }
            }.resume()
        }
    }
}

#Preview {
    AnimeSearchView()
}
