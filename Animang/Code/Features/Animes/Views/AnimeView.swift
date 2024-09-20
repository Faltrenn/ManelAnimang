//
//  AnimeView.swift
//  Animang
//
//  Created by Emanuel on 13/08/24.
//

import SwiftUI
import SwiftSoup

struct EpisodeCard: View {
    let link: String
    var body: some View {
        NavigationLink {
            EpisodeView(link: link, selector: .megaflix)
        } label: {
            Text(link)
        }
    }
}

struct AnimeView: View {
    @ObservedObject var anime: Anime
    let selector: AnimeSelector
    
    var body: some View {
        ScrollView {
            Text(anime.title)
                .font(.title)
                .bold()
            AsyncImage(url: URL(string: anime.imageLink)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            ForEach(anime.episodes, id: \.self) { link in
                EpisodeCard(link: link)
            }
        }
        .onAppear {
            fetch(link: anime.link) { res in
                do {
                    let parse = try SwiftSoup.parse(res)
                    var episodesLinks: [String] = []
                    if try parse.select(selector.episodesVideos.1).count > 0 {
                        episodesLinks.append(anime.link)
                    } else {
                        let episodes = try parse.select(selector.episodes)
                        episodesLinks = try episodes.map { try $0.select(selector.episodesVideos.0).attr("href") }
                    }
                    DispatchQueue.main.async {
                        anime.episodes = episodesLinks
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AnimeView(anime: Anime(media: Media(title: "", link: "https://megaflix.ac/serie/big-shot-treinador-de-elite-2021-assistir-online-1683163608/", imageLink: ""), description:  "", episodes: []), selector: .megaflix)
    }
}
