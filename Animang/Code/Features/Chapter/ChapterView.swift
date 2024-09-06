//
//  ChapterView.swift
//  Animang
//
//  Created by Emanuel on 01/08/24.
//

import SwiftUI
import SwiftSoup

struct ChapterView: View {
    let chapterLink: String
    let mangaSelector: MangaSelector
    @State var images: [String] = []
    @State var imageIndex: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<imageIndex, id: \.self) { index in
                    AsyncImage(url: URL(string: images[index])) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .onAppear {
                                    if imageIndex < images.count {
                                        imageIndex += 1
                                    }
                                }
                        } else if phase.error != nil {
                            Color.red
                                .onAppear {
                                    print(phase.error)
                                }
                        } else {
                            ProgressView()
                        }
                    }
                }
                if images.count > 0 {
                    ForEach(imageIndex..<images.count, id: \.self) { _ in
                        ProgressView()
                    }
                }
            }
        }
        .onAppear {
            fetch(link: "\(chapterLink)?style=list") { html in
                do {
                    let parse = try SwiftSoup.parse(html)
                    let elements = try parse.select("div[class=page-break] img")
                    let fetchedImages = try elements.map({ try $0.attr("data-src").replacing("\n", with: "").replacing("http", with: "https") })
  
                    DispatchQueue.main.async {
                        images = fetchedImages
                        imageIndex += 1
                    }
                } catch {
                    print("ERROR: ", error)
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
}

#Preview {
    ChapterView(chapterLink: "https://leitordemanga.com/ler-manga/hunter-x-hunter/portugues-pt-br/capitulo-400/p/1", mangaSelector: .leitorDeManga)
}
 
