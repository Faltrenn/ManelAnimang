//
//  MangaModel.swift
//  Animang
//
//  Created by Emanuel on 02/08/24.
//

import Foundation
import SwiftSoup

class Manga: ObservableObject, Decodable, Encodable {
    @Published var title: String
    @Published var link: String
    @Published var imageLink: String
    @Published var description: String
    @Published var chapters: [Chapter]
    
    init(media: Media, description: String, chapters: [Chapter]) {
        self.title = media.title
        self.link = media.link
        self.imageLink = media.imageLink
        self.description = description
        self.chapters = chapters
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .name)
        try container.encode(link, forKey: .link)
        try container.encode(imageLink, forKey: .imageLink)
        try container.encode(description, forKey: .description)
        try container.encode(chapters, forKey: .chapters)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .name)
        self.link = try container.decode(String.self, forKey: .link)
        self.imageLink = try container.decode(String.self, forKey: .imageLink)
        self.description = try container.decode(String.self, forKey: .description)
        self.chapters = try container.decode([Chapter].self, forKey: .chapters)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, link, imageLink, description, chapters
    }
    
    func refresh(selector: MangaSelector, vm: MangaHomeViewModel) {
        fetch(link: link) { html in
            do {
                let parse = try SwiftSoup.parse(html)
                let title = try parse.select(selector.mediaSelector.title.1).first()?.text() ?? ""
                let image = try parse.select(selector.mediaSelector.imageLink.1).first()?.attr("data-src") ?? ""
                let description = try parse.select(selector.description).first()?.text() ?? ""
                let elements = try parse.select(selector.chapters)
                var chapters: [Chapter] = []
                for element in elements {
                    try chapters.append(Chapter(title: element.text(), link: element.attr("href")))
                }
                DispatchQueue.main.async {
                    self.title = title
                    self.imageLink = image
                    self.description = description
                    if self.chapters.isEmpty {
                        self.chapters = chapters
                    }
                    vm.saveMangas()
                }
            } catch {
                print("ERROR: ", error)
            }
        }
    }
}

class Chapter: ObservableObject, Encodable, Decodable {
    let title: String
    let link: String
    
    @Published var imagesURL: [String] = []
    @Published var downloadedImages: [String] = []
    
    init(title: String, link: String) {
        self.title = title
        self.link = link
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(link, forKey: .link)
        try container.encode(imagesURL, forKey: .imagesURL)
        try container.encode(downloadedImages, forKey: .downloadedImages)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.link = try container.decode(String.self, forKey: .link)
        self.imagesURL = try container.decode([String].self, forKey: .imagesURL)
        self.downloadedImages = try container.decode([String].self, forKey: .downloadedImages)
    }
    
    enum CodingKeys: String, CodingKey {
        case title, link, imagesURL, downloadedImages
    }
    
    func refresh(selector: MangaSelector, vm: MangaHomeViewModel) {
        if imagesURL.isEmpty {
            fetch(link: "\(link)?style=list") { html in
                do {
                    let parse = try SwiftSoup.parse(html)
                    let elements = try parse.select("div[class=page-break] img")
                    let fetchedImages = try elements.map({ try $0.attr("data-src").replacing("\n", with: "").replacing("http", with: "https") })
                    
                    DispatchQueue.main.async {
                        self.imagesURL = fetchedImages
                        vm.saveMangas()
                    }
                } catch {
                    print("ERROR: ", error)
                }
            }
        }
    }
}


struct MangaSelector {
    static let leitorDeManga = MangaSelector(
        mediaSelector: .leitorDeManga,
        description: "div[class=description-summary]",
        chapters: "li[class=wp-manga-chapter] a",
        chapterImages: "div[class=page-break] img"
    )
    
    let mediaSelector: MediaSelector
    let description: String
    let chapters: String
    let chapterImages: String
}
