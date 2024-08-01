//
//  ChapterView.swift
//  Animang
//
//  Created by Emanuel on 01/08/24.
//

import SwiftUI
import SwiftSoup

struct ChapterView: View {
    let link: String = "https://lermangas.me/manga/solo-leveling/capitulo-139/"
    @State var images: [String] = []
    @State var imageIndex: Int = 0
    
    var body: some View {
        ScrollView {
            if images.count > 0 {
                ForEach(images, id: \.self) { link in
                    AsyncImage(url: URL(string: link)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if phase.error != nil {
                            Color.red // Indicates an error.
                        } else {
                            Color.blue // Acts as a placeholder.
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if let url = URL(string: link) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, let html = String(data: data, encoding: .utf8), error == nil {
                        do {
                            let parse = try SwiftSoup.parse(html)
                            let elements = try parse.select("div[class=page-break no-gaps] img")
                            let fetchedImages = try elements.map { try $0.attr("src").trimmingCharacters(in: .whitespacesAndNewlines) }
                            DispatchQueue.main.async {
                                images = fetchedImages
                            }
                        } catch {
                            print("ERROR: ", error)
                        }
                    }
                }.resume()
            } else {
                print("url invalida")
            }
        }
    }
}

#Preview {
    ChapterView()
}
