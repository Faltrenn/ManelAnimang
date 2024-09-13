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
    @EnvironmentObject var mangaHVM: MangaHomeViewModel
    let mangaSelector: MangaSelector
    let docsDir = getDocumentsDirectory()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if chapter.downloadedImages.isEmpty {
                    Text("\(chapter.imagesURL.count) \(chapter.imagesURL)")
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
                        if let img = UIImage(contentsOfFile: docsDir.appending(path:  link).path(percentEncoded: false)) {
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
    @ObservedObject var mangaHVM = MangaHomeViewModel()
    mangaHVM.mangas.first!.chapters.first!.refresh(selector: .leitorDeManga, vm: mangaHVM)
    
    return ChapterView(chapter: mangaHVM.mangas.first!.chapters.first!, mangaSelector: .leitorDeManga)
        .environmentObject(mangaHVM)
}
 
