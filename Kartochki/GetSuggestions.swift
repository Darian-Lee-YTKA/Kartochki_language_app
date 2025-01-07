//
//  GetSuggestions.swift
//  Kartochki
//
//  Created by Darian Lee on 7/22/24.
//

import SwiftUI

struct GetSuggestions: View {
    @State var text: String = ""
    @State var difficulty: String = "beginner"
    @Binding var showingAlert: Bool
    @Binding var alertMessage: String
    @Binding var generatedSentence: String
    @Binding var currentView: ViewType
    @Binding var alertTitle: String

    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    @Binding var language: String
    
    @Binding var inputLanguage: String
    @Binding var translationLanguage: String
    @Binding var front: String
    @Binding var back: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Enter a word or short phrase in \(language) or English and select a difficulty level. Our models will output a sentence which uses this word in context in your target language.")
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            TextField("Enter word...", text: $text)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .foregroundColor(.black)
            
            Picker(selection: $difficulty, label: Text("Difficulty").foregroundColor(.white)) {
                Text("Beginner").tag("beginner")
                Text("Intermediate").tag("intermediate")
                Text("Advanced").tag("advanced")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(pinkFullOpacity)
            .cornerRadius(12)
            Spacer()
            Button(action: {
                let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
                print(words)
                if words.isEmpty {
                    print("no text entered")
                    alertTitle = "Uh oh!"
                    alertMessage = "Please enter at least one word and then try again 🙂"
                    showingAlert = true
                } else if words.count > 4 {
                    print("The text contains more than four words.")
                    alertTitle = "Uh oh!"
                    alertMessage = "Please limit your requests to 4 words or fewer in order to keep computational costs down. We appreciate your understanding 🙂"
                    showingAlert = true
                } else {
                    Task{
                        await fetchExampleSentence()
                    }
                    print("Valid input: \(words)")
                }
            }) {
                Text("Get Sentence")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(pinkFullOpacity)
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
            
 
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        
        
                
        
    }
    private func fetchExampleSentence() async {
            let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            print(words)
            
            
            do {
                let sentence = try await ApiManager().getExampleSentence(language: language, inputText: text, difficulty: difficulty)
                
                if sentence == "Error" || sentence == "Empty" {
                    alertTitle = "Uh oh!"
                    alertMessage = "We were unable to get a sentence at this time. Please ensure that you are inputting a valid word or phrase in " + language
                    showingAlert = true
                }
                else{
                    generatedSentence = sentence
                    print("😾😾😾", sentence)
                    
                    alertTitle = "🤩 Success 🤩"
                    alertMessage = "Sentence generated successfully!"
                    showingAlert = true
                        
                    translationLanguage = "English"
                    inputLanguage = language
                    front = generatedSentence
                    back = ""
                    currentView = .CardCreateView
                          
                }
                
            } catch {
                alertTitle = "Uh oh!"
                alertMessage = "An error occurred while fetching the sentence. Please try again."
                showingAlert = true
            }
        }
    
}




