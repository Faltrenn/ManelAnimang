//
//  MangaHomeViewModel.swift
//  Animang
//
//  Created by Emanuel on 04/08/24.
//

import Foundation
import SwiftUI
import SwiftSoup

class MangaHomeViewModel: ViewModel {
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
    
    func addMedia(media: Media) {
        addManga(media: media)
    }
    
    func removeMedia(media: Media) {
        if let manga = mangas.first(where: { $0.link == media.link } ) {
            removeManga(manga: manga)
        }
    }
    
    func addManga(media: Media) {
        self.mangas.append(Manga(media: media, description: "", chapters: []))
        self.saveMangas()
//        if let url = URL(string: media.link) {
//            URLSession.shared.dataTask(with: url) { data, response, error in
//                if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
//                    do {
//                        let parse = try SwiftSoup.parse(html)
//                        let altName = try parse.select("div[class=post-title]").first()?.text() ?? ""
//                        let genres = try parse.select("div[class=genres-content]").first()?.text() ?? ""
//                        let postStatus = try parse.select("div[class=post-status] div div[class=summary-content]")
//                        let launch = try postStatus[0].text()
//                        let status = try postStatus[1].text()
//                        let score = try parse.select("div[class=post-total-rating allow_vote] div[class=score font-meta total_votes]").text()
//                        DispatchQueue.main.async {
//                        }
//                    } catch {
//                        print("ERROR: ", error)
//                    }
//                }
//            }.resume()
//        }
    }
    
    func hasManga(manga: Manga) -> Bool {
        mangas.contains { $0.link == manga.link }
    }
    
    func removeManga(manga: Manga) {
        if hasManga(manga: manga) {
            withAnimation {
                mangas.removeAll { $0.link == manga.link }
            }
            saveMangas()
        }
    }
    
    func saveMangas() {
        if let encoded = try? JSONEncoder().encode(mangas) {
            UserDefaults.standard.set(encoded, forKey: "mangas")
        }
    }
    
    func reset() {
        mangas.removeAll()
        
        if UserDefaults.standard.data(forKey: "mangas") != nil {
            UserDefaults.standard.removeObject(forKey: "mangas")
        }
    }
}
