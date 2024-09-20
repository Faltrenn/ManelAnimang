//
//  EpisodeView.swift
//  Animang
//
//  Created by Emanuel on 12/08/24.
//

import SwiftUI
import AVKit
import SwiftSoup
import JavaScriptCore

enum Players: String {
    case voe, streamtape
    
    static func getPlayer(iframe link: String, completion: @escaping (AVPlayer) -> Void) {
        switch link.domain! {
        case Players.voe.rawValue:
            Task {
                do {
                    var html = try await fetch(link: link)
                    
                    let link = html.split(separator: "window.location.href = '")[1].split(separator: "'")[0]
                    
                    html = try await fetch(link: String(link))
                    let videoLink = String(html.split(separator: "let nodeDetails = prompt(\"Node\", \"")[1].split(separator: "\"")[0])
                    
                    DispatchQueue.main.async {
                        completion(createPlayer(with: videoLink))
                    }
                } catch {
                    print("ERROR: ", error)
                }
            }
            break
        case Players.streamtape.rawValue:
            Task {
                do {
                    let html = try await fetch(link: link)
                    let id = html.split(separator: "var srclink = $('#")[1].split(separator: "'")[0]
                    let code = String(html.split(separator: "document.getElementById('\(id)').innerHTML = ")[1].split(separator: ";")[0])
                    let link = JSContext().evaluateScript(code)
                    
                    DispatchQueue.main.async {
                        completion(createPlayer(with: link!.toString().fixedUrl()))
                    }
                } catch {
                    print("ERROR: \(error)")
                }
            }
            break
        default:
            print("oxent")
            break
        }
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
    
    Task {
        do {
            let html = try await fetch(request: request)
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
        } catch {
            print("ERROR: \(error)")
        }
    }
}

struct EpisodeView: View {
    @State var link: String
    let selector: AnimeSelector
    @State var player = AVPlayer()
    
    var body: some View { 
        ZStack {
            VideoPlayer(player: player)
        }
        .onAppear {
            Task {
                do {
                    let html = try await fetch(request: URLRequest(url: URL(string: link)!))
                    let parse = try SwiftSoup.parse(html)
                    let link = try parse.select(selector.episodesVideos.1).attr("href")
                    fetchRecursively(request: URLRequest(url: URL(string: link)!), depth: 5) { src in
                        if let src = src {
                            Players.getPlayer(iframe: src) { player in
                                self.player = player
                            }
                        } else {
                            print("errado")
                        }
                    }
                } catch {
                    print("ERROR: \(error)")
                }
            }
        }
    }
}

func createPlayer(with link: String) -> AVPlayer {
    do {
        let request = try createRequest(link: link)
        let asset = AVURLAsset(url: request.url!, options: ["AVURLAssetHTTPHeaderFieldsKey": request.allHTTPHeaderFields ?? [:]])
        let playerItem = AVPlayerItem(asset: asset)
        return AVPlayer(playerItem: playerItem)
    } catch {
        print("ERROR: \(error)")
        return AVPlayer()
    }
}

#Preview {
    EpisodeView(link: "https://streamtape.com/e/17x3ymxAxRFez37/Jumanji.Proxima.Fase.2020.1080p.BluRay.x264-YOL0W.DUAL-RK-POR.mp4", selector: .megaflix)
}
