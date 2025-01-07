//
//  DeckRowView.swift
//  Kartochki
//
//  Created by Darian Lee on 6/14/24.
//

import SwiftUI

struct DeckRowView: View {
    

    //@State private var isCardCreatePresented: Bool = false
    @Binding var currentView: ViewType
    @Binding var bindedLanguage: String // this is where we well set the language for subsequent views
    
    @Binding var databaseManager: DatabaseManager
    
    @Binding var isShowingDeleteDeckAlert: Bool 
    let veryLightGrey = Color(red: 0.85, green: 0.85, blue: 0.85)
    
    var edit: Bool
    var inLanguages: Bool
    @State var foundDueCount: Bool = false
    
    var deck: DeckData
    
    @Binding var killView: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                HStack {
                    Text(deck.emoji)
                        .font(.system(size: 45))
                        .multilineTextAlignment(.leading)
                    
                    VStack(alignment: .leading) {
                        Text(deck.name)
                            .bold()
                        HStack{
                            if !edit {
                                if let dueCount = databaseManager.dueCounts[deck.name] {
                                    if dueCount < 0 {
                                        Text("unable to fetch due count")
                                            .foregroundColor(Color(red: 0.8, green: 0.1, blue: 0.1))
                                    }
                                    else{
                                        Text("due: \(dueCount)")
                                            .foregroundColor(Color(red: 0.8, green: 0.1, blue: 0.1))
                                    }
                                        
                                    
                                }
                                
                                    
                                }
                                
                            
                            Text("total:  \(deck.count)")
                        }
                        .font(.system(size: 15))
                        
                    }
                    
                    Spacer()
                    
                    if !edit {
                        Button(action: {
                            bindedLanguage = deck.name
                            killView = false
                            currentView = .PracticeTimerView
                        }) {
                            Image(systemName: "arrow.right")
                                .padding()
                        }
                    }
                    
                    if edit && inLanguages {
                        Button(action: {
                            bindedLanguage = deck.name
                            isShowingDeleteDeckAlert = true
                            
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.red)
                            
                            
                        }
                        
                    }
                    
                    if edit && !inLanguages {
                        Button(action: {
                            let language = deck.name
                            databaseManager.setLanguages(languages: [language]) { error in
                                if let error = error {
                                    print("Error adding room: \(error.localizedDescription)")
                                }
                            }
                            
                            databaseManager.createDeck(language: language){ error in
                                if let error = error {
                                    print("Error adding room: \(error.localizedDescription)")
                                }
                                
                                
                            }
                            databaseManager.getLanguages{
                            }
                            databaseManager.getDeckData()
                            
                            
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 30))
                            
                            
                        }
                    }
                }
                .padding()
                .background(veryLightGrey)
                .frame(width: geometry.size.width * 0.9, height: 80, alignment: .topLeading)
                .cornerRadius(20)
                .frame(width: geometry.size.width - 2, alignment: .center)
            }
            
        }
        
        .padding(.vertical, 20)
//        .fullScreenCover(isPresented: $isCardCreatePresented) {
//            CardCreateView(translationLanguage: self.deck.name, deck: self.deck)
//        }
        
        
        .onAppear {
            killView = true
            print("getRowViewAppeared!")
            
            print("kill view in deckrow,", killView)
            
            
            if edit {
                self.databaseManager.getLanguages{
                    
                }
                
            }
        }
        
        
    }
}



struct DeleteDeckAlertView: View {
    @Binding var isShowing: Bool
    var language: String
    var onDelete: () -> Void

    var body: some View {
       
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("😧⁉️ Are you sure? ⁉️😧")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Deleting this \(language) will delete all the flashcards associated with it. This action CANNOT be undone.")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()

                    HStack {
                        Button(action: {
                            onDelete()
                            isShowing = false
                        }) {
                            Text("Delete \(language)")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            isShowing = false
                        }) {
                            Text("Go back")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.black)
                .cornerRadius(12)
                .shadow(radius: 10)
                .frame(maxWidth: 300)
            }
            .transition(.opacity)
            .animation(.easeInOut)
        }
    }

