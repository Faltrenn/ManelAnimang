//
//  MangaViewModel.swift
//  Animang
//
//  Created by Emanuel on 16/03/24.
//

import Foundation
import SwiftUI
import SwiftSoup


class MangaViewModel : ObservableObject {
    @Published var mangas: [Manga] = []
    
    func addManga(link: String) {
        guard let url = URL(string: link) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                do {
                    let doc = try SwiftSoup.parse(html)
                    let name = try doc.select("h1").text()
                    let image = try doc.select("div[class=capaMangaInfo] img").attr("src")
                    DispatchQueue.main.async {
                        self.mangas.append(Manga(name: name, image: image, chapters: []))
                    }
                } catch { }
            }
        }.resume()
    }
}

struct Test : View {
    @ObservedObject var vm = MangaViewModel()
    
    var body: some View {
        VStack {
            ForEach(vm.mangas, id: \.self) { manga in
                VStack {
                    Text(manga.name)
                    AsyncImage(url: URL(string: manga.image)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else if phase.error != nil {
                            Text("erro")
                        } else {
                            ProgressView()
                        }
                    }
                }
            }
        }
        .frame(width: 300, height: 500)
        .onAppear {
            vm.addManga(link: "https://lermanga.org/mangas/gods-gambit/")
        }
        .onChange(of: vm.mangas, { oldValue, newValue in
            print(newValue)
        })
    }
}

#Preview {
    Test()
}
