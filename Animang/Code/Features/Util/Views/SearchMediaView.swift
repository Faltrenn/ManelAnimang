//
//  SearchMediaView.swift
//  Animang
//
//  Created by Emanuel on 20/08/24.
//

import SwiftUI
import SwiftSoup

struct MediaSelector {
    static let leitorDeManga = MediaSelector(
        site: "https://leitordemanga.com/?s=%@&post_type=wp-manga",
        elements: "div[class=row c-tabs-item__content]",
        title: ("div div div h3 a", "div[class=col-12 col-sm-12 col-md-12] div[class=post-title] h1"),
        link: "div div a",
        imageLink: ("div div a img", "div[class=summary_image] a img")
    )
    
    let site: String
    let elements: String
    let title: (String, String)
    let link: String
    let imageLink: (String, String)
}

struct MediaCard<VM: ViewModel>: View {
    @EnvironmentObject var vm: VM
    let media: Media
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: media.imageLink)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            Text(media.title)
        }
        .overlay {
            Button("Adicionar") {
                vm.addMedia(media: media)
            }
        }
    }
}

struct SearchMediaView<VM: ViewModel>: View {
    let selector: MediaSelector
    @State var search = ""
    @State var medias: [Media] = []
    @EnvironmentObject var vm: VM
    
    var body: some View {
        VStack {
            HStack {
                TextField("Pesquise pelo nome", text: $search)
                Button("Pesquisar") {
                    medias = []
                    searchMedia(search: search)
                }
            }
            ScrollView {
                ForEach(medias, id: \.link) { media in
                    MediaCard<VM>(media: media)
                }
            }
        }
    }
    
    func searchMedia(search: String) {
        if let url = URL(string: String(format: selector.site, search.searchFormat)) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                    do {
                        let parse = try SwiftSoup.parse(html)
                        for element in try parse.select(selector.elements) {
                            let link = try element.select(selector.link).attr("href")
                            let imageLink = try element.select(selector.imageLink.0).attr("src")
                            let title = try element.select(selector.title.0).text()
                            DispatchQueue.main.async {
                                self.medias.append(Media(title: title, link: link, imageLink: imageLink))
                            }
                        }
                    } catch {
                        print("ERROR: ", error)
                    }
                }
            }.resume()
        }
    }
}

#Preview {
    SearchMediaView<MangaHomeViewModel>(selector: .leitorDeManga)
        .environmentObject(MangaHomeViewModel())
        .padding()
}
