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
    @State var mangaChapters: [String: String] = [:]
    
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
                
                ForEach(Array(mangaChapters.keys), id: \.self) { chapter in
                    NavigationLink {
                        ChapterView(chapterLink: mangaChapters[chapter]!)
                    } label: {
                        Text(chapter)
                    }
                }
            }
        }
        .onAppear {
            if let url = URL(string: mangaLink) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                        do {
                            let parse = try SwiftSoup.parse(html)
                            let title = try parse.select("div[class=post-title]").first()?.text() ?? ""
                            let image = try parse.select("div[class=summary_image] a img").first()?.attr("src") ?? ""
                            let description = try parse.select("div[class=manga-excerpt]").first()?.text() ?? ""
                            let chaptersLinks = try parse.select("li[class=wp-manga-chapter] a").map{ try $0.attr("href") }
                            let chaptersNames = try parse.select("li[class=wp-manga-chapter] a").map{ try $0.text() }
                            
                            var chapters: [String: String] = [:]
                            for c in 0..<chaptersLinks.count {
                                chapters[chaptersNames[c]] = chaptersLinks[c]
                            }
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
    NavigationStack {
        MangaView(mangaLink: "https://lermangas.me/manga/o-cacador-de-destinos-rank-f/")        
    }
}
