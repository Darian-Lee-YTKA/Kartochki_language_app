//
//  DecksView.swift
//  Kartochki
//
//  Created by Darian Lee on 6/13/24.
//

import SwiftUI

struct DecksView: View {
    @Environment(AuthManager.self) var authManager
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @State private var opacity1: Double = 0
    @State private var opacity2: Double = 0
    @State private var opacity3: Double = 0
    @Binding var currentView: ViewType
    @Binding var bindedLanguage: String // including language because this view will call deckRowView which cruciallly must have the authority to change the binded language to what the user selects
    //@State private var isEditDecksViewPresented: Bool = false
    @State var showRows: Bool = false
    @State var isShowingDeleteDeckAlert: Bool = false
    @Binding var killView: Bool
    @Binding var prevView: ViewType
    @Binding var name: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack {
                        
                        if let pic = databaseManager.languages.randomElement() {
                            if ["German", "Hindi", "Italian", "Japanese", "Persian", "Portuguese"].contains(pic){
                                Image(pic)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: geometry.size.height * 0.45)
                                    .frame(width: geometry.size.width + 7)
                                    .clipped()
                                    .edgesIgnoringSafeArea(.top)
                            }
                            else{
                                let imageChoices = [pic, pic + "2"]
                                let image = imageChoices.randomElement() ?? pic
                                Image(image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: geometry.size.height * 0.45)
                                    .frame(width: geometry.size.width + 7)
                                    .clipped()
                                    .edgesIgnoringSafeArea(.top)
                            }
                            
                            
                            
                            let message = databaseManager.getWelcomeMessage(language: pic)
                           
                            
                            Text("\(message) \(name)")
                                .foregroundColor(.white)
                        } else {
                            Text("No picture found")
                                .foregroundColor(.white)
                        }
                        
                    }
                    .opacity(opacity1)
                    .onAppear {
                        withAnimation(Animation.easeOut(duration: 0.5).delay(0.5)) {
                            opacity1 = 1
                        }
                    }
                    if showRows{
                    ScrollView {
                        
                            ForEach(databaseManager.decks, id: \.self) { deck in
                                DeckRowView(currentView: $currentView, bindedLanguage: $bindedLanguage, databaseManager: $databaseManager, isShowingDeleteDeckAlert: $isShowingDeleteDeckAlert, edit: false, inLanguages: true, deck: deck, killView: $killView)
                                    .padding(.vertical, 15)
                                    .frame(width: geometry.size.width - 10)
                            }
                        }
                            .opacity(opacity2)
                            .onAppear {
                                withAnimation(Animation.easeOut(duration: 0.8).delay(0.5)) {
                                    opacity2 = 1
                                }
                            }
                            .padding(.horizontal, 10)
                    }
                }
                
                HStack {
                    Button(action: {
                        authManager.signOut()
                        currentView = .LoginView
                    }) {
                        Text("Log Out")
                            .padding(15)
                            .font(.system(size: 14))
                            .bold()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        currentView = .EditDecksView
                    }) {
                        Text("Edit")
                            .padding(15)
                            .font(.system(size: 14))
                            .bold()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing, 10)
                }
                .opacity(opacity3)
                .onAppear {
                    print("the view appeared")
                    killView = true
                    print("🔫🔫kill view in decks view", killView)
                    databaseManager.getLanguages {
                        print("it ran")
                        databaseManager.fetchDueNumbersForAllLanguages(languages: databaseManager.languages) { error in
                            if let error = error {
                                
                                print("An error occurred: \(error.localizedDescription)")
                            } else {
                                
                                print("Due numbers successfully fetched for all languages.")
                                showRows = true
                                name = databaseManager.name
                                databaseManager.getDeckData()
                                
                            }
                        }
                    }
                    
                    
                    withAnimation(Animation.easeOut(duration: 1).delay(0.5)) {
                        opacity3 = 1
                    }
                    
                    
                }
                .padding(.top, geometry.safeAreaInsets.top - 50)
                .frame(width: geometry.size.width - 10)
            }
        }
    }
}
