//
//  Models:MangaModel.swift
//  Animang
//
//  Created by Emanuel on 16/03/24.
//

import Foundation


struct Manga: Hashable {
    let name: String
    let image: String
    let chapters: [Chapter]
    var lastRead: Chapter?
}

struct Chapter: Hashable{
    let name: String
    let images: [String]
    let read: Bool = false
}
