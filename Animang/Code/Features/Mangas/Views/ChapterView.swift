//
//  ChapterView.swift
//  Animang
//
//  Created by Emanuel on 01/08/24.
//

import SwiftUI
import SwiftSoup

struct ChapterView: View {
    @ObservedObject var chapter: Chapter
    let mangaSelector: MangaSelector
    @EnvironmentObject var mangaHVM: MangaHomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if chapter.downloadedImages.isEmpty {
                    ForEach(chapter.imagesURL, id: \.self) { link in
                        AsyncImage(url: URL(string: link)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                            } else if phase.error != nil {
                                Color.red
                            } else {
                                ProgressView()
                            }
                        }
                    }
                } else {
                    ForEach(chapter.downloadedImages, id: \.self) { link in
                        if let img = UIImage(contentsOfFile: link.removingPercentEncoding!) {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .onAppear {
            chapter.refresh(selector: .leitorDeManga, vm: mangaHVM)
        }
    }
}

#Preview {
    ChapterView(chapter: Chapter(title: "", link: "https://leitordemanga.com/ler-manga/hunter-x-hunter/portugues-pt-br/capitulo-400/p/1"), mangaSelector: .leitorDeManga)
        .environmentObject(MangaHomeViewModel())
}
 
