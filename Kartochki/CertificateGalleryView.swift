//
//  CertificateGalleryView.swift
//  Kartochki
//
//  Created by Darian Lee on 8/30/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct CertificateGalleryView: View {
    @State private var databaseManager = DatabaseManager()
    @Binding var certificate: Certificate
    @Binding var currentView: ViewType

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(databaseManager.certificates) { cert in
                    CertificateView(certificate: cert)
                        .onTapGesture {
                                                   
                            certificate = cert
                                                    
                            currentView = .PastCertificateView
                                                }
                }
            }
            .padding()
        }
        .background(Color.black) 
        .onAppear {
            databaseManager.fetchCertificates() { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}


struct CertificateView: View {
    let certificate: Certificate
    let languagesWithCulturalAndFlagEmojis: [String: String] = [
        "Japanese": "🍣",
        "Spanish": "💃",
        "Chinese": "🐉",
        "Arabic": "🕌",
        "Russian": "🪆",
        "Korean": "🥢",
        "German": "🍺",
        "French": "🥖",
        "Turkish": "☕️",
        "Italian": "🍕",
        "Hindi": "🪷",
        "Urdu": "🏏",
        "Vietnamese": "🍜",
        "Polish": "🏰",
        "Persian": "🍢",
        "Ukrainian": "🥟",
        "Portuguese": "🏖️",
        "Swahili" : "🐘"
    ]
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
       
            if let photoUrl = certificate.photoUrl, !photoUrl.isEmpty {
                WebImage(url: URL(string: photoUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Text(certificate.date)
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
            
       
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack{
                        Text(languagesWithCulturalAndFlagEmojis[certificate.deckName] ?? "")
                            .background(Color.white.opacity(1))
                            .cornerRadius(10)
                            .font(.system(size: 18, weight: .regular))
                        Text(certificate.date)
                    }
                    .font(.system(size: 13, weight: .regular))
                        //.padding(1)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                }
            }
            //.padding(5)
        }
        .frame(width: 100, height: 100)
    }
    
    
}

#Preview {
    CertificateView(certificate: Certificate(goalMessage: "way to go", userMessage: "", photoUrl: "https://firebasestorage.googleapis.com:443/v0/b/kartochki-a6e6a.appspot.com/o/certificates%2FZT5FFdp5PTeiVoQgCf3O6iiBDrl2%2F9F4D1ACE-436D-4453-8DF4-B380F460069C.jpg?alt=media&token=06e6c0ab-a1f7-4d99-a964-bb866f34e1ef", cardIDs: [], deckName: "Swahili", date: "11/14/24"))
}

