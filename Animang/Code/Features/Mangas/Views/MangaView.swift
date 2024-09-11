//
//  MangaView.swift
//  Animang
//
//  Created by Emanuel on 02/08/24.
//

import SwiftUI
import SwiftSoup

class DownloadManager: ObservableObject {
    @Published var progress = 0.0
    @Published var downloading = false
    @ObservedObject var manga: Manga
    @ObservedObject var chapter: Chapter
    let directory: URL
    
    var downloadedImages: [URL] = []
    
    init(manga: Manga, chapter: Chapter) {
        self.manga = manga
        self.chapter = chapter
        self.directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appending(path: "Mangas")
            .appending(path: manga.title)
            .appending(path: chapter.title)
    }
    
    func download(mangaHVM: MangaHomeViewModel) {
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: self.directory.path, isDirectory: &isDirectory) {
            try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
        }
        
        downloading = true
        for (index, link) in chapter.imagesURL.enumerated() {
            if let url = URL(string: link) {
                URLSession.shared.downloadTask(with: url) { local, response, error in
                    if let local = local {
                        let fileDir = self.directory.appending(path: "\(index).\(link.split(separator: ".").last ?? "")")
                        do {
                            try FileManager.default.moveItem(at: local, to: fileDir)
                            self.downloadedImages.append(fileDir)
                            DispatchQueue.main.async {
                                self.progress = Double(self.downloadedImages.count) / Double(self.chapter.imagesURL.count)
                                if self.progress == 1 {
                                    self.downloading = false
                                    self.chapter.downloadedImages = self.downloadedImages.map({ $0.path() })
                                    mangaHVM.saveMangas()
                                }
                            }
                        } catch {
                            print("Error: ", error)
                        }
                    }
                }.resume()
            }
        }
    }
}

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
        Text(chapter.title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 11/255, green: 11/255, blue: 15/255))
            .clipShape(RoundedRectangle(cornerRadius: 15.0))
            .tint(.primary)
            .overlay(alignment: .trailing) {
                if downloader.downloading {
                    Text("\(downloader.progress)")
                } else {
                    Image(systemName: "arrow.down")
                        .onTapGesture {
                            downloader.download(mangaHVM: mangaHVM)
                        }
                }
            }
    }
}

struct MangaView: View {
    @ObservedObject var manga: Manga
    let mangaSelector: MangaSelector
    @State var rotated = false
    @EnvironmentObject var mangaHVM: MangaHomeViewModel
    
    var body: some View {
        ScrollView {
            VStack {
//                Text(manga.title)
//                    .font(.title)
//                    .bold()
//                    .multilineTextAlignment(.center)
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
//                VStack {
//                    Text(manga.description)
//                }
//                .padding()
//                .background(Color(red: 31/255, green: 31/255, blue: 36/255))
//                .clipShape(RoundedRectangle(cornerRadius: 25.0))
//                
//                HStack {
//                    Text("ÚLTIMOS CAPÍTULOS LANÇADOS")
//                    Image(systemName: "arrow.up.arrow.down")
//                        .rotationEffect(.degrees(rotated ? 180 : 0))
//                        .onTapGesture {
//                            withAnimation(.linear(duration: 0.15)) {
//                                rotated.toggle()
//                                manga.chapters.reverse()
//                            }
//                        }
//                }
//                .bold()
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color(red: 21/255, green: 22/255, blue: 29/255))
//                .clipShape(RoundedRectangle(cornerRadius: 25.0))

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
    NavigationStack {
        MangaView(manga: Manga(media: Media(title: "", link: "https://leitordemanga.com/ler-manga/enen-no-shouboutai/", imageLink: ""), description: "", chapters: []), mangaSelector: .leitorDeManga)
    }
    .environmentObject(MangaHomeViewModel())
}
