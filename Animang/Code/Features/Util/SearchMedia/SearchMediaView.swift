//
//  SearchMediaView.swift
//  Animang
//
//  Created by Emanuel on 20/08/24.
//

import SwiftUI

struct Media {
    let link: String
    let title: String
    let imageLink: String
}

struct SearchMediaView: View {
    @State var search = "Rick"
    @State var medias: [Media] = []
    
    var body: some View {
        VStack {
            HStack {
                TextField("Pesquise pelo nome", text: $search)
                Button("Pesquisar") {
                    
                }
            }
            ScrollView {
                
            }
        }
    }
}

#Preview {
    SearchMediaView()
        .padding()
}
