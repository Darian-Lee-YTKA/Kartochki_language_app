//
//  EditDecksView.swift
//  Kartochki
//
//  Created by Darian Lee on 7/16/24.
//

import SwiftUI
import Foundation

struct EditDecksView: View {
    @Environment(AuthManager.self) var authManager
    @Binding var databaseManager: DatabaseManager
    @State private var isDecksViewPresented: Bool = false
    @Binding var language: String
    @Binding var currentView: ViewType
    @State var isShowingDeleteDeckAlert: Bool = false
    @Binding var killView: Bool
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Edit decks")
                    .bold()
                    .foregroundColor(.white)
                
                Button(action: {
                    currentView = .DecksView
                }){
                    Text("Back")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            ForEach(databaseManager.decks, id: \.self) { deck in
                                DeckRowView(currentView: $currentView, bindedLanguage: $language, databaseManager: $databaseManager, isShowingDeleteDeckAlert: $isShowingDeleteDeckAlert, edit: true, inLanguages: true, deck: deck, killView: $killView)
                                    .padding(.vertical, 15)
                                    .frame(width: geometry.size.width - 10)
                            }
                            Spacer()
                            ForEach(databaseManager.nonLanguages, id: \.self) { nonlanguage in
                                DeckRowView(currentView: $currentView, bindedLanguage: $language, databaseManager: $databaseManager, isShowingDeleteDeckAlert: $isShowingDeleteDeckAlert, edit: true, inLanguages: false, deck: DeckData(name: nonlanguage, count: 0, dueCount: 0), killView: $killView)
                                    .padding(.vertical, 15)
                                    .frame(width: geometry.size.width - 10)
                            }
                        }
                        .frame(width: geometry.size.width)
                    }
                }
                .padding(.horizontal, 5)
                if isShowingDeleteDeckAlert{
                    DeleteDeckAlertView(isShowing: $isShowingDeleteDeckAlert, language: language) {
                        print("🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈 we are trying to delete: ", language)
                                                        databaseManager.deleteLanguageAndDeck(language: language) { error in
                                                            if let error = error {

                                                                print("Error deleting language and deck: \(error.localizedDescription)")
                                                            } else {

                                                                print("Successfully deleted language and deck")
                                                                databaseManager.getLanguages{
                                                                    
                                                                }
                                                                databaseManager.getDeckData()
                                                            }
                                                        }
                    }
                }
            }
        }
        .onAppear {
            databaseManager.getLanguages{
                
            }
            databaseManager.getDeckData()
        }
    }
}





