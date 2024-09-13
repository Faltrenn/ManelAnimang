//
//  MangaView.swift
//  Animang
//
//  Created by Emanuel on 02/08/24.
//

import SwiftUI
import SwiftSoup

struct ChapterCard: View {
    @ObservedObject var chapter: Chapter
    @ObservedObject var manga: Manga
    @ObservedObject var downloader: DownloadManager
    @EnvironmentObject var mangaHVM: MangaHomeViewModel
    
    init(chapter: Chapter, manga: Manga) {
        self.chapter = chapter
        self.manga = manga
        self.downloader = DownloadManager(manga: manga, chapter: chapter)
    }
    
    var body: some View {
        VStack {
            Text(chapter.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 11/255, green: 11/255, blue: 15/255))
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                .tint(.primary)
                .overlay(alignment: .trailing) {
                    if downloader.downloading {
                        Text("\(downloader.progress)")
                    } else if (chapter.downloadedImages.isEmpty) {
                        Image(systemName: "arrow.down")
                            .onTapGesture {
                                downloader.download(mangaHVM: mangaHVM)
                            }
                    } else {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                            .onTapGesture {
                                downloader.delete()
                            }
                    }
                }
        }
    }
}

struct MangaView: View {
    @State var rotated = false
    @ObservedObject var manga: Manga
    @EnvironmentObject var mangaHVM: MangaHomeViewModel
    let mangaSelector: MangaSelector
    
    var body: some View {
        ScrollView {
            VStack {
                Text(manga.title)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                AsyncImage(url: URL(string: manga.imageLink)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(Color(red: 31/255, green: 31/255, blue: 36/255))
                        .aspectRatio(425/615, contentMode: .fill)
                        .overlay {
                            ProgressView()
                        }
                }
                VStack {
                    Text(manga.description)
                }
                .padding()
                .background(Color(red: 31/255, green: 31/255, blue: 36/255))
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                
                HStack {
                    Text("ÚLTIMOS CAPÍTULOS LANÇADOS")
                    Image(systemName: "arrow.up.arrow.down")
                        .rotationEffect(.degrees(rotated ? 180 : 0))
                        .onTapGesture {
                            withAnimation(.linear(duration: 0.15)) {
                                rotated.toggle()
                                manga.chapters.reverse()
                            }
                        }
                }
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 21/255, green: 22/255, blue: 29/255))
                .clipShape(RoundedRectangle(cornerRadius: 25.0))

                ForEach(manga.chapters, id: \.link) { chapter in
                    NavigationLink {
                        ChapterView(chapter: chapter, mangaSelector: .leitorDeManga)
                    } label: {
                        ChapterCard(chapter: chapter, manga: manga)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            manga.refresh(selector: .leitorDeManga, vm: mangaHVM)
        }
    }
}

#Preview {
    var mangaHVM = MangaHomeViewModel()
//    mangaHVM.reset()
//    mangaHVM.mangas.first!.chapters.removeAll()
//    mangaHVM.mangas.first!.chapters.removeFirst()
//    mangaHVM.mangas.first!.chapters.first!.link = ""
    
    return NavigationStack {
        MangaView(manga: mangaHVM.mangas.first!, mangaSelector: .leitorDeManga)
    }
    .environmentObject(mangaHVM)
}
