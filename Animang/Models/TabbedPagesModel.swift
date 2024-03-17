//
//  TabbedPagesModel.swift
//  Animang
//
//  Created by Emanuel on 17/03/24.
//

import Foundation

enum TabbedPages : CaseIterable {
    case manga
    case anime
    
    var title: String {
        switch self {
        case .manga:
            "Manga"
        case .anime:
            "Anime"
        }
    }
}

