//
//  MangaHomeViewModel.swift
//  Animang
//
//  Created by Emanuel on 04/08/24.
//

import Foundation
import SwiftSoup

class MangaHomeViewModel: ObservableObject {
    @Published var mangas: [Manga] = []
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "mangas") {
            do {
                mangas = try JSONDecoder().decode([Manga].self, from: data)
            } catch {
                print("ERROR: ", error)
            }
        }
    }
    
    func addManga(link: String) {
        if let url = URL(string: link) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                    do {
                        let parse = try SwiftSoup.parse(html)
                        let name = try parse.select("div[class=post-title]").first()?.text() ?? ""
                        let altName = try parse.select("div[class=post-title]").first()?.text() ?? ""
                        let imageLink = try parse.select("div[class=summary_image] a img").first()?.attr("src") ?? ""
                        let genres = try parse.select("div[class=genres-content]").first()?.text() ?? ""
                        let postStatus = try parse.select("div[class=post-status] div div[class=summary-content]")
                        let launch = try postStatus[0].text()
                        let status = try postStatus[1].text()
                        let score = try parse.select("div[class=post-total-rating allow_vote] div[class=score font-meta total_votes]").text()
                        DispatchQueue.main.async {
                            self.mangas.append(Manga(name: name, altName: altName, imageLink: imageLink, link: link, genres: genres, status: status, launch: launch, lastChapter: "none", score: score))
                            self.saveMangas()
                        }
                    } catch {
                        print("ERROR: ", error)
                    }
                }
            }.resume()
        }
    }
    
    func hasManga(manga: Manga) -> Bool {
        mangas.contains { $0.link == manga.link }
    }
    
    func removeManga(manga: Manga) {
        if hasManga(manga: manga) {
            mangas.removeAll { $0.link == manga.link }
            saveMangas()
        }
    }
    
    func saveMangas() {
        if let encoded = try? JSONEncoder().encode(mangas) {
            UserDefaults.standard.set(encoded, forKey: "mangas")
        }
    }
}
