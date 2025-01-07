//
//  EditCardView.swift
//  Kartochki
//
//  Created by Darian Lee on 7/21/24.
//

import SwiftUI

struct EditCardView: View {
    
    @Environment(AuthManager.self) var authManager
    @Binding var databaseManager: DatabaseManager
    @State var apiManager: ApiManager = ApiManager()
    
    @Binding var front: String
    @Binding var back: String
    
    @State var translationOutput: String = "Back"
    @Binding var translationLanguage: String
    @Binding var inputLanguage: String
    @State var showMoreInputLanguage: String = "Afrikaans"
    @State private var showMoreLanguagesPicker: Bool = false
    @State private var selectedMoreLanguage: String = "Afrikaans"
    
    @Binding var showingAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    @Binding var currentView: ViewType
    
    @Binding var language: String
    
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    @Binding var existingCard: Card
    
    @Binding var deleteCardAlert: Bool
    
    @State private var showPopUpAlert: Bool = false
    @State private var showPopUpAlertProblem: Bool = false
    var body: some View {
        ZStack {
            Spacer()
            VStack {
                HStack {
                    Button(action: {
                        currentView = .Back
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 30, height: 20)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        guard !front.isEmpty && !back.isEmpty else {
                            showPopUpAlertProblem = true
                            return
                        }
                        
                        var editedCard = existingCard
                        editedCard.front = front
                        editedCard.back = back
                        databaseManager.editCardInDeck(deckName: language, editedCard: editedCard) { error in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                print("success")
                                showPopUpAlert = true
                            }
                        }
                    }) {
                        Text("Update")
                            .foregroundColor(pinkFullOpacity)
                    }
                }
                
                Text("Edit card in " + language)
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
                
                TextField("Front text", text: $front, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if showMoreLanguagesPicker {
                    MoreLanguagesPicker(selectedLanguage: $selectedMoreLanguage, selectedInputLanguage: $showMoreInputLanguage, userLanguages: databaseManager.languages + ["English"])
                        .padding()
                }
                
                HStack {
                    Button(action: {
                        var langForAPI: String = "English"
                        var inputForAPI: String = "English"
                        print("hit button")
                        
                        if translationLanguage == "more" {
                            langForAPI = selectedMoreLanguage
                            inputForAPI = showMoreInputLanguage
                        } else {
                            langForAPI = translationLanguage
                            inputForAPI = inputLanguage
                        }
                        
                        Task {
                            do {
                                print("Pressed button")
                                back = try await apiManager.getTranslation(translationLanguage: langForAPI, inputText: front, inputLanguage: inputForAPI)
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    }) {
                        HStack {
                            Text("Translate back")
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(pinkFullOpacity)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    
                    Picker(selection: $translationLanguage, label: Text("Language")) {
                        Text("En to " + language).tag(language)
                        Text(language + " to En").tag("English")
                        Text("See more options").tag("more")
                    }
                    .tint(pinkFullOpacity)
                    .onChange(of: translationLanguage) { oldValue, newValue in
                        if newValue == "more" {
                            showMoreLanguagesPicker = true
                        } else {
                            showMoreLanguagesPicker = false
                        }
                        if newValue == language {
                            inputLanguage = "English"
                            translationLanguage = language
                        }
                        if newValue == "English" {
                            inputLanguage = language
                            translationLanguage = "English"
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }
                
                Button(action: {
                    let temp = front
                    front = back
                    back = temp
                }) {
                    HStack {
                        Text("Swap")
                            .foregroundColor(pinkFullOpacity)
                        Image(systemName: "arrow.right.arrow.left")
                            .foregroundColor(pinkFullOpacity)
                    }
                }
                .padding()
                
                TextField("Back text", text: $back, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .frame(minHeight: 50)
                
                Text("(Or type your own front and back in the box)")
                    .foregroundColor(.white)
                    .font(.caption)
                
                Spacer()
                
                Button(action: {
                    print("toggling delete card alert")
                    deleteCardAlert = true
                }) {
                    HStack {
                        Text("Delete card")
                            .foregroundColor(.red)
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
            
            // Pop-up alerts
            if showPopUpAlert {
                AlertPopupView(title: "⭐ Success! ⭐", message: "Card updated successfully", displaySeconds: 2) {
                    showPopUpAlert = false
                    currentView = .Back
                }
            }
            if showPopUpAlertProblem {
                AlertPopupView(title: "Uh oh!", message: "Please make sure to add both a front and a back", displaySeconds: 2) {
                    showPopUpAlertProblem = false
                }
            }
        }
    }
}
