//
//  EpisodeView.swift
//  Animang
//
//  Created by Emanuel on 12/08/24.
//

import SwiftUI
import AVKit
import SwiftSoup


//func createPlayer(with link: String) -> AVPlayer {
//    guard let url = URL(string: link) else {
//        return AVPlayer()
//    }
//
//    var request = URLRequest(url: url)
//    request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
//    
//    let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": request.allHTTPHeaderFields ?? [:]])
//    let playerItem = AVPlayerItem(asset: asset)
//    return AVPlayer(playerItem: playerItem)
//}
//
//struct EpisodeView: View {
//    let link = "https://rr2---sn-uphcg51pa-bpbz.googlevideo.com/videoplayback?expire=1723520931&ei=I2e6ZsHoHO7jxtYPivG7-Qg&ip=2804:214:85db:d2bd:1977:8f05:1266:cc4f&id=b0e8cc4eadccf7f0&itag=18&source=blogger&xpc=Egho7Zf3LnoBAQ%3D%3D&mh=Rw&mm=31&mn=sn-uphcg51pa-bpbz&ms=au&mv=m&mvi=2&pl=48&susc=bl&eaua=dj08VIqlCF8&mime=video/mp4&vprv=1&rqh=1&dur=1393.615&lmt=1598393324113096&mt=1723491916&txp=1311224&sparams=expire,ei,ip,id,itag,source,xpc,susc,eaua,mime,vprv,rqh,dur,lmt&sig=AJfQdSswRQIgVXk9JA3PYsweOD9LTC0I8m3YhzpoeqUsrIkqzsdaJLsCIQD1kpnvLlSQXtHsMTaiGAUTWQR1W7rZPD-nlCydKD5GAQ%3D%3D&lsparams=mh,mm,mn,ms,mv,mvi,pl&lsig=AGtxev0wRgIhAO8RPUEedB8WaiLyjyMD7XLyHyj4ahqehfafdK2O3mbmAiEAjBXtbL_eHNZIeflZLKl0NYqmdG-cYCEiryGaYJN9m-w%3D"
//
//    var body: some View {
//        VideoPlayer(player: createPlayer(with: link))
//    }
//}

struct Episode: Codable {
    let thumbnail: String
    let streams: [Stream]
}

struct Stream: Codable {
    let playURL: String
    let formatID: Int

    enum CodingKeys: String, CodingKey {
        case playURL = "play_url"
        case formatID = "format_id"
    }
}

struct EpisodeView: View {
    let link = "https://aniturept.blogspot.com/2021/12/demon-slayer-1x01-legendado-online.html"
    @State var player: AVPlayer?
    
    var body: some View {
        VStack {
            if player != nil {
                VideoPlayer(player: player)
            }
        }
            .onAppear {
                fetch(link: link) { res in
                    do {
                        let link2 = try SwiftSoup.parse(res).select("iframe").attr("src")
                        fetch(link: link2) { res in
                            do {
                                let script = try SwiftSoup.parse(res).select("script").html()
                                let json = script.split(separator: "= ")[1].description.data(using: .utf8)!
                                
                                let vc = try JSONDecoder().decode(Episode.self, from: json)
                                player = createPlayer(with: vc.streams.first!.playURL)
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
