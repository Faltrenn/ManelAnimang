//
//  Models.swift
//  Animang
//
//  Created by Emanuel on 09/09/24.
//

import Foundation

extension String {
    var searchFormat: String {
        self.replacingOccurrences(of: " ", with: "+")
    }
}

protocol ViewModel: ObservableObject {
    func addMedia(media: Media)
    func removeMedia(media: Media)
}

struct Media {
    let title: String
    let link: String
    let imageLink: String
}
