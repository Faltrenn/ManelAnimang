//
//  AnimeView.swift
//  Animang
//
//  Created by Emanuel on 13/08/24.
//

import SwiftUI
import SwiftSoup

struct Anime {
    let name: String
    let imageLink: String
    let description: String
    let episodesLinks: [String]
}

struct AnimeView: View {
    let link = "https://aniturept.blogspot.com/2021/12/demon-slayer-episodios-legendado-online.html"
    @State var anime: Anime?
    
    var body: some View {
        ScrollView {
            if let anime = anime {
                Text(anime.name)
                    .font(.title)
                    .bold()
                AsyncImage(url: URL(string: anime.imageLink)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                ForEach(anime.episodesLinks, id: \.self) { link in
                    Text(link)
                }
            }
        }
        .onAppear {
            fetch(link: link) { res in
                do {
                    let html = try SwiftSoup.parse(res)
                    let name = try html.select("h1[class=post-title entry-title] a").text()
                    let imagelink = try html.select("td img").attr("src")
                    let description = ""
//                    let episodesLinks = try html.select("div[class=arquivos] a").map { try $0.attr("href") }
                    var episodesLinks: [String] = []
                    for div in try html.select("div[class=arquivos]") {
                        for e in try div.select("a").reversed() {
                            if try e.attr("style") == "" {
                                episodesLinks.append(try e.attr("href"))
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        anime = Anime(name: name, imageLink: imagelink, description: description, episodesLinks: episodesLinks)
                    }
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func fetch(link: String, completion: @escaping (String) -> Void) {
        if let request = createRequest(link: link) {
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                    completion(html)
                }
            }.resume()
        }
    }
    
    func createRequest(link: String) -> URLRequest? {
        if let url = URL(string: link) {
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
            return request
        }
        return nil
    }
}

#Preview {
    AnimeView()
}
