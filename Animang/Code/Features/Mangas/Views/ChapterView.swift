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
                        } else if phase.error != nil {
                            Color.red
                        } else {
                            ProgressView()
                        }
                    }
                }
            }
        }
        .onAppear {
            fetch(link: "\(chapterLink)?style=list") { html in
                do {
                    let parse = try SwiftSoup.parse(html)
                    let elements = try parse.select("div[class=page-break] img")
                    let fetchedImages = try elements.map({ try $0.attr("data-src").replacing("\n", with: "").replacing("http", with: "https") })
  
                    DispatchQueue.main.async {
                        images = fetchedImages
                        loadNextImage()
                    }
                } catch {
                    print("ERROR: ", error)
                }
            } 
        }
    }
    
    func loadNextImage() {
        if imageIndex < images.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                imageIndex += 1
                loadNextImage()
            }
        }
    }
}

#Preview {
    ChapterView(chapterLink: "https://leitordemanga.com/ler-manga/hunter-x-hunter/portugues-pt-br/capitulo-400/p/1", mangaSelector: .leitorDeManga)
}
 
