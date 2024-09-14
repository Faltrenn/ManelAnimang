//
//  Anime.swift
//  Animang
//
//  Created by Emanuel on 13/09/24.
//

import Foundation

struct AnimeSelector {
    static let megaflix = AnimeSelector(
        mediaSelector: .megaflix,
        episodes: "ul[id=episode_by_temp] li",
        episodesVideos: "article a"
    )
    
    let mediaSelector: MediaSelector
    let episodes: String
    let episodesVideos: String
}

class Anime: Media {
    @Published var description: String
    @Published var episodes: [String]
    
    enum CodingKeys: String, CodingKey {
        case title, link, imageLink, description, episodes
    }
    
    init(media: Media, description: String, episodes: [String]) {
        self.description = description
        self.episodes = episodes
        super.init(media: media)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(description, forKey: .description)
        try container.encode(episodes, forKey: .episodes)
        try super.encode(to: encoder)
    }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decode(String.self, forKey: .description)
        self.episodes = try container.decode([String].self, forKey: .episodes)
        try super.init(from: decoder)
    }
}
