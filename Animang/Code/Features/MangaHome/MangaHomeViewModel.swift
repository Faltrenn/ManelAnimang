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
                        }
                    } catch {
                        print("ERROR: ", error)
                    }
                }
            }.resume()
        }
    }
}
