//
//  EditGoalScreen.swift
//  Kartochki
//
//  Created by Darian Lee on 7/29/24.
//

import SwiftUI

struct EditGoalScreen: View {
    @Binding var language: String
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @Environment(AuthManager.self) var authManager
    @Binding var mode: GoalMode
    @Binding var count: Int
    
    @Binding var showTimer: Bool
    @Binding var showCardsLearned: Bool
    @Binding var ascending: Bool
    
    @State private var showingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var goal: GoalPreference? = nil
    @Binding var currentView: ViewType
    @Binding var killView: Bool
    
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    let darkGrey = Color(red: 40/255, green: 45/255, blue: 45/255)

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Edit goal for deck: " + language)
                    .font(.title)
                    .foregroundColor(pinkFullOpacity)
                
                HStack {
                    Text("I want to study")
                        .foregroundColor(.white)
                    
                    TextField("15", value: $count, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 40)
                        .padding(3)
                        .background(Color.white)
                        .cornerRadius(5)
                    
                    Picker(selection: $mode, label: Text("").foregroundColor(.white)) {
                        Text("cards").tag(GoalMode.Cards)
                        Text("minutes").tag(GoalMode.Minutes)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
                .padding()
                
                if mode == .Cards {
                    Toggle(showTimer ? "Show Timer" : "Show Timer", isOn: $showTimer)
                        .foregroundColor(.white.opacity(0.9))
                        .toggleStyle(SwitchToggleStyle(tint: pinkFullOpacity))
                        .padding()
                }
                
                if mode == .Minutes {
                    Toggle(showCardsLearned ? "Show Cards Learned" : "Show Cards Learned", isOn: $showCardsLearned)
                        .foregroundColor(.white)
                        .toggleStyle(SwitchToggleStyle(tint: pinkFullOpacity))
                        .padding()
                }
                
                Toggle(ascending ? "count up" : "count down", isOn: $ascending)
                    .foregroundColor(.white)
                    .toggleStyle(SwitchToggleStyle(tint: pinkFullOpacity))
                    .padding()
                
                HStack {
                    Button(action: {
                        killView = false
                        currentView = .PracticeViews
                    }) {
                        Text("Back")
                            .foregroundColor(.red)
                    }
                    Spacer()
                    Button(action: {
                        print("pressed done")
                        if let deck = databaseManager.decks.first(where: { $0.name == language }) {
                            if mode == .Cards && count > deck.count {
                                alertTitle = "You only have \(deck.count) card(s) available in your current deck. Please pick a goal no higher than this amount"
                                alertMessage = ""
                                showingAlert = true
                            } else if mode == .Minutes && count > 150 {
                                alertTitle = "Please select a time goal smaller than 150 minutes (2.5 hours)"
                                alertMessage = ""
                                showingAlert = true
                            } else {
                                goal = GoalPreference(goalMode: mode, count: count, showTimer: showTimer, showCardsLearned: showCardsLearned, ascending: ascending, language: language)
                                databaseManager.changeGoalPreference(language: language, newPreference: goal ?? GoalPreference(goalMode: .Minutes, count: 10, showTimer: true, showCardsLearned: true, ascending: false, language: "Spanish")) { error in
                                    if let error = error {
                                        print(error)
                                    } else {
                                        print("success")
                                        killView = false
                                        currentView = .PracticeTimerView
                                    }
                                }
                            }
                        } else {
                            goal = GoalPreference(goalMode: mode, count: count, showTimer: showTimer, showCardsLearned: showCardsLearned, ascending: ascending, language: language)
                            databaseManager.changeGoalPreference(language: language, newPreference: goal ?? GoalPreference(goalMode: .Minutes, count: 10, showTimer: true, showCardsLearned: true, ascending: false, language: "Spanish")) { error in
                                if let error = error {
                                    print(error)
                                } else {
                                    print("success")
                                    killView = false
                                    currentView = .PracticeTimerView
                                }
                            }
                        }
                    }) {
                        Text("Done")
                            .foregroundColor(pinkFullOpacity)
                    }
                }
                .padding()
            }
            .padding()
            .background(darkGrey)
            .cornerRadius(12)
            .padding()
            .onAppear {
                killView = false
                databaseManager.getDeckData()
            }
            
            if showingAlert {
                AlertPopupView(title: alertTitle, message: alertMessage, displaySeconds: 4) {
                    showingAlert = false
                }
            }
        }
    }
}

    



struct GoalPreference{
    let goalMode: GoalMode
    let count: Int
    let showTimer: Bool
    let showCardsLearned: Bool
    let ascending: Bool
    let language: String
    
}
