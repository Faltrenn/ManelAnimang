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
        if self.hasPrefix("//") {
            return "https:" + self
        } else if self.hasPrefix("/") {
            return "https:/" + self
        }
        return self
    }
    
    var domain: String? {
        var formattedLink = self.fixedUrl()
        if !formattedLink.hasPrefix("http://") && !formattedLink.hasPrefix("https://") {
            formattedLink = "https://" + formattedLink
        }
        
        if let url = URLComponents(string: formattedLink), let host = url.host {
            let components = host.components(separatedBy: ".")
            if components.count > 2 && components[0] == "www" {
                return components[1]
            } else if components.count > 1 {
                return components[0]
            }
        }
        
        return nil
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

func fetch(request: URLRequest) async throws -> String {
    let (data, _) = try await URLSession.shared.data(for: request)
    guard let html = String(data: data, encoding: .utf8) else {
        throw URLError(.badServerResponse)
    }
    return html
}

func fetch(link: String) async throws -> String {
    return try await fetch(request: createRequest(link: link))
}

func createRequest(link: String) throws -> URLRequest {
    if let url = URL(string: link) {
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        return request
    }
    throw URLError(.badURL)
}

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}
