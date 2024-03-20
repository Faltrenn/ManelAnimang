//
//  MangaView.swift
//  Animang
//
//  Created by Emanuel on 20/03/24.
//

import SwiftUI

struct MangaView: View {
    var manga: Manga
    var body: some View {
        Text(manga.name)
    }
}

#Preview {
    MangaView(manga: Manga(name: "opa", image: "", chapters: []))
}
