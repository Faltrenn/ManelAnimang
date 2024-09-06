//
//  MangaModel.swift
//  Animang
//
//  Created by Emanuel on 02/08/24.
//

import Foundation

struct Chapter {
    let title: String
    let link: String
}

struct MangaSelector {
    static let leitorDeManga = MangaSelector(
        mediaSelector: .leitorDeManga,
        description: "div[class=manga-excerpt]",
        chapters: "li[class=wp-manga-chapter] a",
        chapterImages: "div[class=page-break no-gaps] img"
    )
    
    let mediaSelector: MediaSearchSelector
    let description: String
    let chapters: String
    let chapterImages: String
}
