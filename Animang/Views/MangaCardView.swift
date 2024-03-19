//
//  MangaCardView.swift
//  Animang
//
//  Created by Emanuel on 18/03/24.
//

import SwiftUI

struct MangaCardView: View {
    let manga: Manga
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: manga.image)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else if phase.error != nil {
                    Text("Error")
                } else {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible(minimum: 100)), GridItem(.flexible(minimum: 100))]) {
        MangaCardView(manga: Manga(name: "", image: "https://img.lermanga.org/R/return-of-the-sss-class-ranker/capa.jpg", chapters: []))
        MangaCardView(manga: Manga(name: "", image: "https://img.lermanga.org/R/return-of-the-sss-class-ranker/capa.jpg", chapters: []))
        MangaCardView(manga: Manga(name: "", image: "https://img.lermanga.org/R/return-of-the-sss-class-ranker/capa.jpg", chapters: []))
    }
}
