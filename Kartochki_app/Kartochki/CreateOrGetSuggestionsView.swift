//
//  CreateOrGetSuggestionsView.swift
//  Kartochki
//
//  Created by Darian Lee on 7/22/24.
//

import SwiftUI

struct CreateOrGetSuggestionsView: View {
    
   // @State var isShowingCreateCard: Bool = false
    //@State var isShowingGetSuggestions: Bool = false
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    
 // just so I can make sure to clean these variables before going to the next view
    @Binding var currentView: ViewType
    @Binding var language: String
    @Binding var inputLanguage: String
    @Binding var translationLanguage: String
    @Binding var front: String
    @Binding var back: String
    
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                //isShowingCreateCard.toggle()
                
                inputLanguage = "English"
                translationLanguage = language
                front = ""
                back = ""
                currentView = .CardCreateView
            }) {
                Text("Create card from scratch")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .foregroundColor(pinkFullOpacity)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            Text("or")
                .foregroundColor(.black)
                .padding(.bottom, 10)
            
            Button(action: {
                currentView = .GetSuggestions
            }) {
                Text("Get customized card ideas using AI")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .foregroundColor(pinkFullOpacity)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Image("kartochkilogoPink1")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 300)
                .padding(.vertical, 10)
            
        }
        .padding()
        .background(pinkFullOpacity)
        
        .edgesIgnoringSafeArea(.all)
       
    }
}



