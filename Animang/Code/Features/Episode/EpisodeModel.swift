//
//  EpisodeModel.swift
//  Animang
//
//  Created by Emanuel on 13/08/24.
//

import Foundation

struct Episode: Codable {
    let thumbnail: String
    let streams: [Stream]
}

struct Stream: Codable {
    let playURL: String
    let formatID: VideoFormats
    
    enum VideoFormats: Int, Codable {
        case qvga = 7
        case sd = 18
        case hd = 22
        case fhd = 37
    }

    enum CodingKeys: String, CodingKey {
        case playURL = "play_url"
        case formatID = "format_id"
    }
}
