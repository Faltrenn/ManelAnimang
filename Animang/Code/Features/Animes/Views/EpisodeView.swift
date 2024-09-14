//
//  EpisodeView.swift
//  Animang
//
//  Created by Emanuel on 12/08/24.
//

import SwiftUI
import AVKit
import SwiftSoup

extension String {
    var domain: String? {
        var formattedLink = self
        if formattedLink.hasPrefix("//") {
            formattedLink = "https:" + formattedLink
        } else if !formattedLink.hasPrefix("http://") && !formattedLink.hasPrefix("https://") {
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

func fetchRecursively(request: URLRequest, depth: Int, completion: @escaping (String?) throws -> Void) {
    guard depth > 0 else {
        do {
            try completion(nil)
        } catch {
            print("ERROR:", error)
        }
        return
    }
    
    fetch(request: request) { html in
        let parse = try SwiftSoup.parse(html)
        let iframe = try parse.select("iframe")
        guard iframe.count == 0 else {
            try completion(try iframe.attr("src"))
            return
        }
        let link = try parse.select("form").attr("action")
        let inputs = try parse.select("form input")
        var keys: [String: String] = [:]
        for input in inputs {
            keys[try input.attr("name")] = try input.attr("value")
        }
        
        var postRequest = URLRequest(url: URL(string: String(link))!)
        postRequest.httpMethod = "POST"
        let body = keys.map { "\($0.key)=\($0.value)" }
                             .joined(separator: "&")
        postRequest.httpBody = body.data(using: .utf8)
        
        fetchRecursively(request: postRequest, depth: depth - 1, completion: completion)
    }
}

struct EpisodeView: View {
    @State var link: String
    @State var player = AVPlayer()
    
    var body: some View { 
        ZStack {
            VideoPlayer(player: player)
        }
        .onAppear {
            fetch(request: URLRequest(url: URL(string: link)!)) { html in
                let parse = try SwiftSoup.parse(html)
                let link = try parse.select("aside[class=video-player aa-cn] div a").attr("href")
                fetchRecursively(request: URLRequest(url: URL(string: link)!), depth: 5) { src in
                    if let src = src {
                        print(src)
                        self.player = createPlayer(with: src)
                    }
                }
            }
        }
    }
    
    func createPlayer(with link: String) -> AVPlayer {
        guard let request = createRequest(link: link) else {
            return AVPlayer()
        }
    
        let asset = AVURLAsset(url: request.url!, options: ["AVURLAssetHTTPHeaderFieldsKey": request.allHTTPHeaderFields ?? [:]])
        let playerItem = AVPlayerItem(asset: asset)
        return AVPlayer(playerItem: playerItem)
    }
}

#Preview {
    EpisodeView(link: "https://megaflix.ac/episodio/big-shot-treinador-de-elite-1x1/")
}
