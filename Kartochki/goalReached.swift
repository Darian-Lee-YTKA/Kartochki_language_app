//
//  goalReached.swift
//  Kartochki
//
//  Created by Darian Lee on 8/28/24.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct GoalReached: View {
    @Binding var name: String
    @Binding var goalMode: GoalMode
    @Binding var count: Int
    @Binding var language: String
    @Binding var killView: Bool 
    @State private var player: AVAudioPlayer?
    @State private var animateStamp = false
    @State private var showConfetti = false
    @Binding var currentView: ViewType
    @Binding var alreadyReachedGoal: [String]
    @State var userMessage: String = ""
    @Binding var cardIDs: [String]
    @State var showCardView: Bool = false
    @State var showPopupAlert: Bool = false
    @State var databaseManager = DatabaseManager()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State var alreadySaved: Bool = false
    var body: some View {
        GeometryReader { geometry in
            
                ZStack {
                    
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    Image("scroll-clipped")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height * 1.1)
                        .ignoresSafeArea(.all)
                        .overlay(
                            VStack{
                                HStack{
                                    Button(action: {
                                            killView = false
                                            currentView = .PracticeViews
                                        }) {
                                            Image(systemName: "arrow.backward")
                                                
                                                .foregroundStyle(.black)
                                        }

                                        Spacer()
                                    
                                    Button(action: {
                                  
                                        print("already saved: \(alreadySaved)")
                                        if alreadySaved == false {
                                            alreadySaved = true
                                            
                                            let date = formatDateToMMDD()
                                            databaseManager.saveCertificate(goalMessage: goalText(), userMessage: userMessage, cardIDs: cardIDs, deckName: language, photo: selectedItem ?? nil, date: date){
                                                error in
                                                if let error = error{
                                                    print(error.localizedDescription)
                                                }
                                                else{
                                                    showPopupAlert = true
                                                }
                                                
                                                
                                            }
                                        }
                                        else{
                                            
                                            print("already saved")
                                        }
                                        
                                    }){
                                        Image(systemName: "square.and.arrow.down")
                                                   
                                                    .foregroundStyle(.black)
                                            }
                                            
                                
                                    Spacer()
                                    Button(action: {
                                        currentView = .CertificateGalleryView
                                    }){
                                        Image(systemName: "photo.on.rectangle")
                                                    
                                                    .foregroundStyle(.black)
                                            }
                                        }
                                .frame(width: geometry.size.width * 0.9, alignment: .center)
                     
                                ScrollView{
                                    VStack {
                                       
                                            
                                        
                                        
                                        
                                        PhotosPicker(
                                            selection: $selectedItem,
                                            matching: .images,
                                            photoLibrary: .shared()) {
                                                if let selectedImageData,
                                                   let uiImage = UIImage(data: selectedImageData) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 180, height: 180)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.brown, lineWidth: 4))
                                                        .shadow(radius: 10)
                                                        .padding(.bottom, 10)
                                                } else {
                                                    Circle()
                                                        .strokeBorder(Color.brown, lineWidth: 4)
                                                        .frame(width: 170, height: 170)
                                                        .overlay(
                                                            Text("Upload Photo")
                                                                .foregroundColor(.black)
                                                                .fontWeight(.bold)
                                                        )
                                                        .shadow(radius: 10)
                                                        .padding(.bottom, 10)
                                                }
                                            }
                                            .padding(.top, 10)
                                            .onChange(of: selectedItem) { oldItem, newItem in
                                                Task {
                                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                                        selectedImageData = data
                                                    }
                                                }
                                            }
                                        
                                        
                                        Text("Certificate of Achievement")
                                            .font(.system(size: geometry.size.width * 0.065))
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                            .padding(.bottom, geometry.size.height * 0.01)
                                            .frame(width: geometry.size.width * 0.9, alignment: .center)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.center)
                                        
                                        Text(goalText())
                                            .font(.system(size: geometry.size.width * 0.04))
                                            .frame(width: geometry.size.width * 0.9, alignment: .center)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, geometry.size.width * 0.08)
                                            .padding(.vertical, 10)
                                        
                                        TextField("Add a note...", text: $userMessage, axis: .vertical)
                                            .frame(width: geometry.size.width * 0.9, alignment: .center)
                                            .foregroundStyle(.brown)
                                            .italic()
                                            .padding(.vertical, 10)
                                        Text("-\(name)")
                                            .italic()
                                            .padding(.vertical, 5)
                                        
                                        Button(action: {
                                            print("pressed button")
                                            showCardView.toggle()
                                        }){
                                            Text("See cards studied: (click then scroll down)")
                                                .font(.system(size: 12))
                                        }
                                        .foregroundStyle(.brown)
                                        if showCardView{
                                            CardsView(ids: cardIDs, language: language)
                                                .ignoresSafeArea(.all)
                                            
                                        }
                                        
                                    }
                                }
                                .frame(height: geometry.size.height * 0.6, alignment: .top)
                                HStack{
                                    
                                    
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
                        
                    if showPopupAlert {
                        AlertPopupView(title: "⭐ Success! ⭐", message: "Certificate saved successfully", displaySeconds: 2) {
                            showPopupAlert = false
                            
                        }
                    }
                   
                        let hRange = -110...110
                        let vRange = -200...200
                        let vList: [CGFloat] = vRange.map { CGFloat($0) }
                        let hList: [CGFloat] = hRange.map { CGFloat($0) }
                        ForEach(0..<50) { index in
                            ConfettiPiece(
                                verticalOffset: vList.randomElement()!,
                                horizontalOffset: geometry.size.width * CGFloat(index) / hList.randomElement()!
                            )
                        }
                        .transition(.opacity)
                    }
                
                

            
                               
            }
            .onAppear {
                alreadyReachedGoal = alreadyReachedGoal + [language]
                playTrumpetSound()
                withAnimation(.easeInOut(duration: 1.5)) {
                    animateStamp = true
                    
                }
                withAnimation(Animation.easeInOut(duration: 1.5)) {
                                   showConfetti = true
                               }
                
             
            }
        }
    
    
    private func goalText() -> String {
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        
        if goalMode == .Minutes {
            return "On this day \(dateString), \(name) completed their goal of learning \(language) for \(count) minutes."
        } else {
            return "On this day \(dateString), \(name) completed their goal of reviewing \(count) cards in \(language)."
        }
    }
    private func formatDateToMMDD() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: Date())
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









struct ConfettiPiece: View {
    let verticalOffset: CGFloat
    let horizontalOffset: CGFloat
    @State private var offset: CGFloat = -UIScreen.main.bounds.height

    var body: some View {
        Rectangle()
            .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.8, green: 0.6, blue: 0.3), // Dark bronze
                                Color(red: 1.0, green: 0.84, blue: 0.0), // Bright gold
                               
                                Color(red: 0.95, green: 0.85, blue: 0.5),
                               
                                Color(red: 1.0, green: 0.84, blue: 0.0), // Bright gold
                                Color(red: 0.8, green: 0.6, blue: 0.3), // Dark bronze
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
        
            .frame(width: 20, height: 40)
            .rotationEffect(.degrees(Double.random(in: 0...360)))
            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 1, y: 1)
            .offset(x: horizontalOffset, y: offset)
       
            .font(.title)
            .onAppear {
                withAnimation(Animation.linear(duration: 6.0)) {
                    self.offset = UIScreen.main.bounds.height + verticalOffset
                }
            }
    }
}


struct CardsView: View {
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @State var cards: [Card] = []
    var ids: [String]
    var language: String
    
    var body: some View {
        VStack {
            if cards.isEmpty {
                Text("No cards found")
            } else {
                VStack(spacing: 0) {
                    ForEach(cards, id: \.id) { card in
                        HStack {
                 
                            Text(card.front)
                                .font(.system(size: 12))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                            
                           
                            Divider()
                                .frame(width: 1)
                                .background(Color.black)
                            
                           
                            Text(card.back)
                                .font(.system(size: 12))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxHeight: .infinity)
                        .frame(width: 300, alignment: .center)
                        .border(Color.black, width: 1)
                    }
                }
            }
        }

        .onAppear {
            print("cards view called!")
            databaseManager.getCardsWithCertainIDs(language: language, IDs: ids) { fetchedCards, error in
                if let error = error {
                    print("Could not find cards: \(error.localizedDescription)")
                } else if let fetchedCards = fetchedCards {
                    cards = fetchedCards
                    print("we found: \(cards)")
                }
            }
        }
    }
}


