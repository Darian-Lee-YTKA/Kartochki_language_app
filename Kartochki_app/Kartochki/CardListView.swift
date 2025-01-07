//
//  CardListView.swift
//  Kartochki
//
//  Created by Darian Lee on 7/21/24.
//

import SwiftUI


struct CardListView: View {
    @Binding var databaseManager: DatabaseManager
    @Binding var language: String
    @Environment(AuthManager.self) var authManager
   
    @Binding var selectedCard: Card
    @State var dueOrOverdueCards: [Card] = []
    @Binding var translationLanguage: String
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    @State private var searchText: String = ""
    @State private var filteredCards: [Card] = []
    @Binding var currentView: ViewType
    @Binding var front: String
    @Binding var back: String
    
    @Binding var killView: Bool

    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("")
                Text("")
                Text("")
                HStack {
                    Button(action: {
                        currentView = .DecksView
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 30, height: 23)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        killView = false
                        currentView = .PracticeTimerView
                    }) {
                        Image(systemName: "play.square.stack.fill")
                       
                            .resizable()
                            .frame(width: 23, height: 23)
                            .foregroundColor(pinkFullOpacity)
                            .padding(4)
                    }
                    
                    Button(action: {
                        currentView = .CreateOrGetSuggestionsView
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 23, height: 23)
                            .foregroundColor(pinkFullOpacity)
                            .padding(4)
                            .cornerRadius(8)
                    }
                }
               
                
                VStack {
                    Text(selectedCard.front)
                        .foregroundColor(.black)
                    
                    TextField("Search...", text: $searchText)
                        .foregroundColor(.white)
                        .padding(3.5)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .onChange(of: searchText) { oldValue, newValue in
                            filteredCards = databaseManager.AllCards.filter { card in
                                card.front.localizedCaseInsensitiveContains(newValue) ||
                                card.back.localizedCaseInsensitiveContains(newValue)
                            }
                        }
                    
                    ScrollView {
                        ForEach(searchText.isEmpty ? databaseManager.AllCards : filteredCards, id: \.self) { card in
                            Button(action: {
                                selectedCard = card
                                
                                translationLanguage = language
                                front = selectedCard.front
                                back = selectedCard.back
                                currentView = .EditCardView
                            }) {
                                CardListRow(card: card)
                            }
                        }
                    }
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
                }
                .background(Color.black)
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            killView = true

            databaseManager.getAllCardsInDeck(deckName: language)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    print(databaseManager.AllCards)
                }
            }
        
    }
}

struct CardListRow: View {
    
    var card: Card
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    init(card: Card) {
        self.card = card
       
    }

    var body: some View {
            VStack(alignment: .leading, spacing: 2) { 
                Text(card.front)
                    .font(.body)
                    .foregroundColor(pinkFullOpacity)
                    .lineLimit(1)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 1)
                
                Text(card.back)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(7)
            
            
        
        }
    }

 


