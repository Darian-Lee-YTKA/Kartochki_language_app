//
//  CardCreateView.swift
//  Kartochki
//
//  Created by Darian Lee on 7/16/24.
//

import SwiftUI

struct CardCreateView: View {
    @Environment(AuthManager.self) var authManager
    @Binding var databaseManager: DatabaseManager
    @State var apiManager: ApiManager = ApiManager()
    @Binding var front: String
    @State var back: String = ""
    @State var translationOutput: String = "Back"
    @Binding var translationLanguage: String
    @Binding var inputLanguage: String
    @State var showMoreInputLanguage: String = "Afrikaans"
    @State private var showMoreLanguagesPicker: Bool = false
    @State private var selectedMoreLanguage: String = "Afrikaans"
    @Binding var showingAlert: Bool
    @Binding var alertMessage: String
    @Binding var alertTitle: String
    @Binding var currentView: ViewType
    @State private var showPopUpAlert: Bool = false
    @State private var showPopUpAlertProblem: Bool = false
    //@State var takeMeBack: Bool = false
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    @Binding var language: String
    @Binding var prevView: ViewType
    @Binding var killView: Bool
   

    var body: some View {
        ZStack{
           
            
            
            Spacer()
            VStack {
                HStack {
                    Button(action: {
                        killView = false
                        currentView = .CardListView //will change later
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
                        if front == "~~0053"{ //for testing
                            databaseManager.add50CardsForDeveloperTest(language: language)
                            showPopUpAlert = true
                            print("success")
                        }
                        
                        else{
                            let card = Card(front: front, back: back, dueDate: Date(), id: nil, oldInterval: 0)
                            databaseManager.addCardToDeck(deckName: language, card: card) { error in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    showPopUpAlert = true
                                    
                                    
                                    print("success")
                                    
                                    
                                }
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(pinkFullOpacity)
                            .padding(4)
                            .cornerRadius(8)
                    }
                }
                Text("Add card to " + language)
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
                
                TextField("Front", text: $front, axis: .vertical)
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
                        
                        if translationLanguage == "more"{
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
                        if newValue == language{
                            inputLanguage = "English"}
                        if newValue == "English" {
                            inputLanguage = language
                        }
                        
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }
                Button(action: {
                    let temp = front
                    front = back
                    back = temp
                    
                    
                }){
                    HStack{
                        Text("Swap")
                            .foregroundColor(pinkFullOpacity)
                        Image(systemName: "arrow.right.arrow.left")
                            .foregroundColor(pinkFullOpacity)
                    }
                }
                .padding()
                
                
                
                TextField("Back", text: $back, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .frame(minHeight: 50)
                
                //Spacer()
                Text("(Or type your own front and back in the box)")
                    .foregroundColor(.white)
                    .font(.caption)
                Spacer()
                
                
            }
            if showPopUpAlert {
                AlertPopupView(title: "⭐ Success! ⭐", message: "New card added successly to " + language, displaySeconds: 2) {
                    showPopUpAlert = false
                    front = ""
                    back = ""
                }
            }
            if showPopUpAlertProblem {
                AlertPopupView(title: "Uh oh!", message: "Please make sure to add both a front and a back", displaySeconds: 2) {
                    showPopUpAlertProblem = false
                    front = ""
                    back = ""
                }
            }

        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        
        
        .onAppear {
            killView = true
            prevView = .CardCreateView
            //needed to show saved languages in the more languages selector
            databaseManager.getDeckData()
            databaseManager.getLanguages{
                
            }
            
        }
    
    }
}

struct MoreLanguagesPicker: View {
    @Binding var selectedLanguage: String
    @Binding var selectedInputLanguage: String
    let userLanguages: [String]
    let additionalLanguages = [
        "Afrikaans", "Arabic", "Bengali", "Chinese", "Dutch", "English", "French",
        "German", "Greek", "Hebrew", "Hindi", "Indonesian", "Italian", "Japanese",
        "Korean", "Malay", "Persian", "Polish", "Portuguese", "Romanian", "Russian",
        "Spanish", "Swahili", "Swedish", "Tamil", "Thai", "Turkish", "Ukrainian",
        "Urdu", "Vietnamese", "Zulu"
    ]
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.black.opacity(0.85))
                .shadow(color: Color.white.opacity(1), radius: 5, x: 10, y: 10)
                .frame(height: 120)
            
            VStack {
                HStack{
                    Text("From ")
                    
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    
                    Picker(selection: $selectedInputLanguage, label: Text("Language")) {
                                    Group {
                                        Text("_____ SAVED _____").font(.headline)
                                        ForEach(userLanguages, id: \.self) { language in
                                            Text(language)
                                                .foregroundColor(.white)
                                                .tag(language)
                                        }
                                    }
                                    
                                    Group {
                                        Text("__________________").font(.headline)
                                        ForEach(additionalLanguages, id: \.self) { language in
                                            Text(language)
                                                .foregroundColor(.white)
                                                .tag(language)
                                        }
                                    }
                                }
                    
                    
                    
                    .tint(pinkFullOpacity)
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
                HStack{
                    Text("To ")
                    
                        .bold()
                        .foregroundColor(.white) // Set text color to white
                        .padding()
                    
                    Picker(selection: $selectedLanguage, label: Text("Language")) {
                        Group {
                            Text("_____ SAVED _____").font(.headline)
                            ForEach(userLanguages, id: \.self) { language in
                                Text(language)
                                    .foregroundColor(.white)
                                    .tag(language)
                            }
                        }
                        
                        Group {
                            Text("_____________").font(.headline)
                            ForEach(additionalLanguages, id: \.self) { language in
                                Text(language)
                                    .foregroundColor(.white)
                                    .tag(language)
                            }
                        }
                    }
                    
                    
                    
                    .tint(pinkFullOpacity)
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
            }
        }
        .padding()
    }
}



