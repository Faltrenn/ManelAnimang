//
//  ChapterView.swift
//  Animang
//
//  Created by Emanuel on 01/08/24.
//

import SwiftUI
import SwiftSoup

struct ChapterView: View {
    let chapterLink: String
    let mangaSelector: MangaSelector
    @State var images: [String] = []
    @State var imageIndex: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<imageIndex, id: \.self) { index in
                    AsyncImage(url: URL(string: images[index])) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .onAppear {
                                    if imageIndex < images.count {
                                        imageIndex += 1
                                    }
                                }
                        } else if phase.error != nil {
                            Color.red
                        } else {
                            ProgressView()
                        }
                    }
                }
                ForEach(imageIndex..<images.count, id: \.self) { _ in
                    ProgressView()
                }
            }
        }
        .onAppear {
            if let url = URL(string: chapterLink) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, let html = String(data: data, encoding: .utf8), error == nil {
                        do {
                            let parse = try SwiftSoup.parse(html)
                            let elements = try parse.select(mangaSelector.chapterImages)
                            let fetchedImages = try elements.map { try $0.attr("src").trimmingCharacters(in: .whitespacesAndNewlines) }
                            DispatchQueue.main.async {
                                images = fetchedImages
                                imageIndex += 1
                            }
                        } catch {
                            print("ERROR: ", error)
                        }
                    }
                }.resume()
            } else {
                print("url invalida")
            }
        }
    }
}

#Preview {
    ChapterView(chapterLink: "https://lermangas.me/manga/solo-leveling/capitulo-139/", mangaSelector: .leitorDeManga)
}
