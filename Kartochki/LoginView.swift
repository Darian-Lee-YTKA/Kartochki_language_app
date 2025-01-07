//
//  ContentView.swift
//  Kartochki
//
//  Created by Darian Lee on 6/4/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) var authManager
    @State private var imageOffset: CGFloat = -800
    @State private var loginButtonOffset: CGFloat = -800
    @State private var signUpButtonOffset: CGFloat = -800
    @State private var imageOpacity: Double = 0
    @State private var loginButtonOpacity: Double = 0
    @State private var signUpButtonOpacity: Double = 0
    @State private var email: String = ""
    @State private var password: String = ""
    //@State private var showCreateAccount: Bool = false
    @Binding var currentView: ViewType
    @Binding var showingAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.red.opacity(0.2)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        Image("kartochkilogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.4)
                            .foregroundStyle(.tint)
                            .offset(y: imageOffset)
                            .opacity(imageOpacity)
                            .onAppear {
                                withAnimation(Animation.easeOut(duration: 1).delay(1.5)) {
                                    imageOffset = 0
                                    imageOpacity = 1
                                }
                            }
                        
                        Spacer()
                        VStack{
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)
                        .offset(y: imageOffset)
                        .opacity(imageOpacity)
                        .onAppear {
                            withAnimation(Animation.easeOut(duration: 1).delay(1.1)) {
                                imageOffset = 0
                                imageOpacity = 1
                            }
                        }
                        .padding()
                        
                        Button(action: {
                            print("Login button tapped")
                            authManager.signIn(email: email, password: password) { success in
                                if !success {
                                    alertTitle = "Login Error"
                                    alertMessage = "Incorrect username or password"
                                    showingAlert = true
                                }
                                else {
                                    print("👩🏻‍🦰", authManager.user)
                                    print("go to decks view")
                                    currentView = .DecksView
                                }
                            }
                        }) {
                            Text("Login")
                                .font(.title2)
                                .padding(geometry.size.height * 0.005)
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        .padding(.horizontal, geometry.size.width * 0.1)
                        .offset(y: loginButtonOffset)
                        .opacity(loginButtonOpacity)
                        .onAppear {
                            withAnimation(Animation.easeOut(duration: 1).delay(0.8)) {
                                loginButtonOffset = 0
                                loginButtonOpacity = 1
                            }
                        }
                        
                        Button(action: {
                            
                            currentView = .CreateAccountView
                        }) {
                            Text("Create new account")
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
//                        .fullScreenCover(isPresented: $showCreateAccount) {
//                            CreateAccountView(
//                                currentView: $currentView,
//                                showingAlert: $showingAlert,
//                                alertTitle: $alertTitle,
//                                alertMessage: $alertMessage
//                            )
//                            .environment(authManager)
//                        }
                        .padding(.horizontal, 65)
                        .offset(y: signUpButtonOffset)
                        .opacity(signUpButtonOpacity)
                        .onAppear {
                            withAnimation(Animation.easeOut(duration: 1).delay(0.5)) {
                                signUpButtonOffset = 0
                                signUpButtonOpacity = 1
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                
            }
            
        }
    }
}


