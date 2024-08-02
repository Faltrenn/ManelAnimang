//
//  MangaView.swift
//  Animang
//
//  Created by Emanuel on 02/08/24.
//

import SwiftUI
import SwiftSoup

struct MangaView: View {
    let mangaLink: String
    @State var mangaTitle: String = ""
    @State var mangaImage: String = ""
    @State var mangaDescription: String = ""
    @State var mangaChapters: [String] = []
    
    var body: some View {
        ScrollView {
            VStack {
                Text(mangaTitle)
                AsyncImage(url: URL(string: mangaImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                Text(mangaDescription)
                
                ForEach(mangaChapters, id: \.self) { chapterLink in
                    Text(chapterLink)
                }
                
            }
        }
        .onAppear {
            if let url = URL(string: mangaLink) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                        do {
                            let parse = try SwiftSoup.parse(html)
                            let title = try parse.select("div[class=post-title]").first()!.text()
                            let image = try parse.select("div[class=summary_image] a img").first()!.attr("src")
                            let description = try parse.select("div[class=manga-excerpt]").first()!.text()
                            let chapters = try parse.select("li[class=wp-manga-chapter] a").map{ try $0.attr("href") }
                            DispatchQueue.main.async {
                                mangaTitle = title
                                mangaImage = image
                                mangaDescription = description
                                mangaChapters = chapters
                            }
                        } catch {
                            print("ERROR: ", error)
                        }
                    }
                }
                .resume()
            }
        }
    }
}

#Preview {
    MangaView(mangaLink: "https://lermangas.me/manga/o-cacador-de-destinos-rank-f/")
}
