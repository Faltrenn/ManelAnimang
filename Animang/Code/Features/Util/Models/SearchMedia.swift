//
//  Models.swift
//  Animang
//
//  Created by Emanuel on 09/09/24.
//

import Foundation

extension String {
    func searchFormat(separator: String) -> String {
        self.replacingOccurrences(of: " ", with: separator)
    }
    
    func fixedUrl() -> String {
        return self.starts(with: "//") ? "https:" + self : self
    }
}

protocol ViewModel: ObservableObject {
    func addMedia(media: Media)
    func removeMedia(media: Media)
}

class Media: ObservableObject, Encodable, Decodable {
    @Published var title: String
    @Published var link: String
    @Published var imageLink: String
    
    enum CodingKeys: String, CodingKey {
        case name, link, imageLink
    }
    
    init(title: String, link: String, imageLink: String) {
        self.title = title
        self.link = link
        self.imageLink = imageLink
    }
    
    init(media: Media) {
        self.title = media.title
        self.link = media.link
        self.imageLink = media.imageLink
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .name)
        try container.encode(link, forKey: .link)
        try container.encode(imageLink, forKey: .imageLink)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .name)
        self.link = try container.decode(String.self, forKey: .link)
        self.imageLink = try container.decode(String.self, forKey: .imageLink)
    }
}

func fetch(request: URLRequest, completion: @escaping (String) throws -> Void) {
    URLSession.shared.dataTask(with: request) { data, response, error in
        if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
            do {
                try completion(html)
            } catch {
                print("ERROR:", error)
            }
        } else {
            print(error as Any)
        }
    }.resume()
}

func fetch(link: String, completion: @escaping (String) -> Void) {
    fetch(request: createRequest(link: link)!, completion: completion)
}

func createRequest(link: String) -> URLRequest? {
    if let url = URL(string: link) {
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        return request
    }
    return nil
}
