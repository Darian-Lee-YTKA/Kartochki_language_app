//
//  PastCertificate.swift
//  Kartochki

//  Created by Darian Lee on 8/30/24.
//


import SwiftUI
import AVFoundation
import PhotosUI

struct PastCertificate: View {
    @Binding var certificate: Certificate
    @Binding var killView: Bool
    @State private var player: AVAudioPlayer?
    @Binding var currentView: ViewType
    @State var showPopupAlert: Bool = false
 

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    Image("scroll-clipped")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height * 1.1)
                        .ignoresSafeArea(.all)
                        .overlay(
                            VStack {
                                HStack {
                                    Button(action: {
                                        killView = false
                                        currentView = .DecksView
                                    }) {
                                        Image(systemName: "arrow.backward")
                                            .foregroundStyle(.black)
                                    }
                                    
                                    Spacer()
                                    
                                   
                                    
                                  
                                    
                                    Button(action: {
                                        currentView = .CertificateGalleryView
                                    }) {
                                        Image(systemName: "photo.on.rectangle")
                                            .foregroundStyle(.black)
                                    }
                                }
                                .frame(width: geometry.size.width * 0.9, alignment: .center)
                                
                                ScrollView {
                                    VStack {
                                        if let photoUrl = certificate.photoUrl, let url = URL(string: photoUrl) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 180, height: 180)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(Color.brown, lineWidth: 4))
                                                    .shadow(radius: 10)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Circle()
                                                .strokeBorder(Color.brown, lineWidth: 4)
                                                .frame(width: 170, height: 170)
                                                .overlay(
                                                    Text("No Photo Available")
                                                        .foregroundColor(.black)
                                                        .fontWeight(.bold)
                                                )
                                        }
                                        
                                        Text("Certificate of Achievement")
                                            .font(.system(size: geometry.size.width * 0.065))
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                            .padding(.bottom, geometry.size.height * 0.01)
                                            .multilineTextAlignment(.center)
                                        
                                        Text(certificate.goalMessage)
                                            .font(.system(size: geometry.size.width * 0.04))
                                            .frame(width: geometry.size.width * 0.9, alignment: .center)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, geometry.size.width * 0.08)
                                            .padding(.vertical, 10)
                                        
                                        Text(certificate.userMessage)
                                            .frame(width: geometry.size.width * 0.9, alignment: .center)
                                            .foregroundStyle(.brown)
                                            .italic()
                                            .padding(.vertical, 10)
                                            
                                                                                  
                                        
                                        Button(action: {
                                            print("Show cards")
                                        }) {
                                            Text("See cards studied:")
                                                .font(.system(size: 12))
                                        }
                                        .foregroundStyle(.brown)
                                        
                                        CardsView(ids: certificate.cardIDs, language: certificate.deckName)
                                            .ignoresSafeArea(.all)
                                    }
                                }
                                .frame(height: geometry.size.height * 0.6, alignment: .top)
                                
                                HStack {
                                    Spacer()
                                    Image("kartochki_stamp")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .shadow(radius: 10)
                                        .transition(.scale)
                                }
                                .padding(.horizontal, geometry.size.width * 0.05)
                            }
                            .frame(height: geometry.size.height * 0.8, alignment: .center)
                        )
                }
                
                if showPopupAlert {
                    AlertPopupView(title: "⭐ Success! ⭐", message: "Certificate saved successfully", displaySeconds: 2) {
                        showPopupAlert = false
                    }
                }
            }
            .onAppear {
                print("past certificate viewk called")
                playTrumpetSound()
                
            }
        }
    }

  

    private func playTrumpetSound() {
        guard let url = Bundle.main.url(forResource: "tada_guitar", withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound")
        }
    }
}

struct MockCertificate {
    static let example = Certificate(
        goalMessage: "Achieved 100% Mastery in French Deck",
        userMessage: "Keep up the great work!",
        photoUrl: nil,
        cardIDs: ["card1", "card2", "card3"],
        deckName: "French", date: "11/12/21"
    )
}




struct PastCertificate_Preview: View {
    @State private var certificate = MockCertificate.example
    @State private var killView = false
    @State private var currentView: ViewType = .PracticeViews

    var body: some View {
        PastCertificate(
            certificate: $certificate,
            killView: $killView,
            currentView: $currentView
        )
    }
}

struct PastCertificate_Previews: PreviewProvider {
    static var previews: some View {
        PastCertificate_Preview()
    }
}
