//
//  EpisodeView.swift
//  Animang
//
//  Created by Emanuel on 12/08/24.
//

import SwiftUI
import AVKit
import SwiftSoup

struct EpisodeView: View {
    let link = "https://aniturept.blogspot.com/2021/12/demon-slayer-1x01-legendado-online.html"
    @State var player = AVPlayer()
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
        }
            .onAppear {
                fetch(link: link) { res in
                    do {
                        let link2 = try SwiftSoup.parse(res).select("iframe").attr("src")
                        fetch(link: link2) { res in
                            do {
                                let script = try SwiftSoup.parse(res).select("script").html()
                                let json = script.split(separator: "= ")[1].description.data(using: .utf8)!
                                
                                let ep = try JSONDecoder().decode(Episode.self, from: json)
                                DispatchQueue.main.async {
                                    player = createPlayer(with: ep.streams.first!.playURL)
                                }
                            } catch {
                                print(error)
                            }
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
    EpisodeView()
}
