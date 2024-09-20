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
        imageLink: ("div div a img", "div[class=summary_image] a img"),
        separator: "-"
    )
    
    static let megaflix = MediaSelector(
        site: "https://megaflix.ac/?s=%@",
        elements: "ul[class=post-lst rw sm rcl2 rcl3a rcl4b rcl3c rcl4d rcl6e] li",
        title: ("h2[class=entry-title]", "aside[class=fg1] header h1"),
        link: "a",
        imageLink: ("div[class=post-thumbnail or-1] figure img", "div[class=post-thumbnail alg-ss] figure img"),
        separator: "+"
    )
     
    let site: String
    let elements: String
    let title: (String, String)
    let link: String
    let imageLink: (String, String)
    let separator: String
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
    @State var search = "big shot"
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
        .onAppear() {
            searchMedia(search: search) 
        }
    }
    
    func searchMedia(search: String) {
        Task {
            do {
                let html = try await fetch(link: String(format: selector.site, search.searchFormat(separator: selector.separator)))
                
                let parse = try SwiftSoup.parse(html)
                for element in try parse.select(selector.elements) {
                    let link = try element.select(selector.link).attr("href")
                    let imageLink = try element.select(selector.imageLink.0).attr("src").fixedUrl()
                    let title = try element.select(selector.title.0).text()
                    DispatchQueue.main.async {
                        self.medias.append(Media(title: title, link: link, imageLink: imageLink))
                    }
                }
            } catch {
                print("Error: ", error.localizedDescription)
            }
        }
    }
}

#Preview {
    SearchMediaView<MangaHomeViewModel>(selector: .leitorDeManga)
        .environmentObject(AnimeHomeViewModel())
        .padding()
}
