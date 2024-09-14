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

struct Media {
    let title: String
    let link: String
    let imageLink: String
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
