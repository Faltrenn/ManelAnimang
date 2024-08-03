//
//  MangaHomeView.swift
//  Animang
//
//  Created by Emanuel on 03/08/24.
//

import SwiftUI
import SwiftSoup

struct Manga {
    let name: String
    let link: String
    let imageLink: String
}

struct MangaHomeView: View {
    @State var links = [
        "https://lermangas.me/manga/solo-leveling/",
        "https://lermangas.me/manga/eu-pertenco-a-familia-castielo/",
        "https://lermangas.me/manga/uma-princesa-que-le-a-sorte/",
        "https://lermangas.me/manga/reencarnando-como-o-herdeiro-louco/",
        "https://lermangas.me/manga/acima-de-todos-os-deuses/"
    ]
    
    @State var mangas: [Manga] = []
    
    var body: some View {
        VStack {
            Button("Adicionar") {
                addManga()
            }
            ScrollView {
                VStack {
                    ForEach(mangas, id: \.link) { manga in
                        VStack {
                            NavigationLink {
                                MangaView(mangaLink: manga.link)
                            } label: {
                                VStack {
                                    Text(manga.name)
                                    AsyncImage(url: URL(string: manga.imageLink)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addManga() {
        if !links.isEmpty {
            let link = links.removeFirst()
            if let url = URL(string: link) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                        do {
                            let parse = try SwiftSoup.parse(html)
                            let title = try parse.select("div[class=post-title]").first()?.text() ?? ""
                            let image = try parse.select("div[class=summary_image] a img").first()?.attr("src") ?? ""
                            DispatchQueue.main.async {
                                mangas.append(Manga(name: title, link: link, imageLink: image))
                            }
                        } catch {
                            print("ERROR: ", error)
                        }
                    }
                }.resume()
            }
        }
    }
}

#Preview {
    NavigationStack {
        MangaHomeView()
    }
}
