//
//  AnimeViewModel.swift
//  Animang
//
//  Created by Emanuel on 13/09/24.
//

import Foundation
import SwiftUI

class AnimeHomeViewModel: ViewModel {
    @Published var animes: [Anime] = []
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "animes") {
            do {
                animes = try JSONDecoder().decode([Anime].self, from: data)
            } catch {
                print("ERROR: ", error)
            }
        }
    }
    
    func addMedia(media: Media) {
        addAnime(media: media)
    }
    
    func removeMedia(media: Media) {
        if let anime = animes.first(where: { $0.link == media.link } ) {
            removeAnime(anime: anime)
        }
    }
    
    func addAnime(media: Media) {
        self.animes.append(Anime(media: media, description: "", episodes: []))
        self.saveAnimes()
    }
    
    func hasAnime(anime: Anime) -> Bool {
        animes.contains { $0.link == anime.link }
    }
    
    func removeAnime(anime: Anime) {
        if hasAnime(anime: anime) {
            withAnimation {
                animes.removeAll { $0.link == anime.link }
            }
            saveAnimes()
        }
    }
    
    func saveAnimes() {
        if let encoded = try? JSONEncoder().encode(animes) {
            UserDefaults.standard.set(encoded, forKey: "animes")
        }
    }
}
