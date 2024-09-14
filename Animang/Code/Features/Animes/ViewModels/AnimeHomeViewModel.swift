//
//  AnimeViewModel.swift
//  Animang
//
//  Created by Emanuel on 13/09/24.
//

import Foundation

class AnimeHomeViewModel: ViewModel {
    @Published var animes: [Anime]
    
    init() {
        self.animes = []
    }
    
    func addMedia(media: Media) {
        addAnime(media: media)
    }
    
    func removeMedia(media: Media) {
        removeAnime(media: media)
    }
    
    func addAnime(media: Media) {
        
    }
    
    func removeAnime(media: Media) {
        
    }
}
