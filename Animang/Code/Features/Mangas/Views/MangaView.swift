//
//  MangaView.swift
//  Animang
//
//  Created by Emanuel on 02/08/24.
//

import SwiftUI
import SwiftSoup

struct ChapterCard: View {
    let title: String
    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 11/255, green: 11/255, blue: 15/255))
            .clipShape(RoundedRectangle(cornerRadius: 15.0))
            .tint(.primary)
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
                        ChapterView(chapterLink: chapter.link, mangaSelector: .leitorDeManga)
                    } label: {
                        ChapterCard(title: chapter.title)
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
        MangaView(manga: Manga(media: Media(title: "", link: "https://lermangas.me/manga/o-cacador-de-destinos-rank-f/", imageLink: ""), description: "", chapters: []), mangaSelector: .leitorDeManga)
            .environmentObject(MangaHomeViewModel())
    }
}
