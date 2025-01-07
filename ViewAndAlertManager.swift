//
//  ViewAndAlertManager.swift
//  Kartochki
//
//  Created by Darian Lee on 8/13/24.
//

import SwiftUI





struct ViewAndAlertManager: View {
    @State var currentView: ViewType = .DecksView
    @State private var bindedLanguage: String = "Russian"
    @State private var alertMessage: String = "Something went wrong"
    @State private var alertTitle: String = "Error"
    @State private var showingAlert: Bool = false
    @State private var generatedSentence: String = ""
    @State private var showingAlertWithUndo: Bool = false
    @State private var selectedCard: Card = Card(front: "something went wrong", back: "something went wrong", dueDate: Date(), id: "123", oldInterval: 0)
    
    @State private var inputLanguage: String = "English"
    @State private var translationLanguage: String = "Russian"
    @State private var front: String = ""
    @State private var back: String = ""
    @State private var cardsTilReset: Int = 0
    
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @State var cardUndoManager: CardUndoManager = CardUndoManager()
    @StateObject var timerManager: TimerManager = TimerManager()
    @State var deleteCardAlert: Bool = false
    
    @State var prevView: ViewType = .DecksView
    @State var showEditCardModular: Bool = false
    @State var killView: Bool = true// because swiftUI keeps randomly switching back to Practice view ahhhhh I hate it. its dead! I already killed it. How can I kill what has already died
    @State private var viewStack: [ViewType] = []
    @State var certificate: Certificate = Certificate(goalMessage: "", userMessage: "", photoUrl: nil, cardIDs: ["card"], deckName: "", date: "")
    
    @Environment(AuthManager.self) var authManager
    
    @State var name: String = ""
    
    // use these to change EditGoal View
    @State var goalMode: GoalMode = .Minutes
    @State var goalCount: Int = 15
    @State var showTimer: Bool = true
    @State var showCardsLearned: Bool = true
    @State var ascending: Bool = false
    @State var alreadyReachedGoal: [String] = []
    @State var cardIDs: [String] = []
    
    var body: some View {
        VStack{
            switch currentView {
            case .LoginView:
                LoginView(
                    currentView: $currentView,
                    showingAlert: $showingAlert,
                    alertTitle: $alertTitle,
                    alertMessage: $alertMessage
                )
                .environment(authManager)
            case .CreateAccountView:
                CreateAccountView(
                    currentView: $currentView
                )
                .environment(authManager)
            case .EditGoalScreen:
                EditGoalScreen(language: $bindedLanguage, mode: $goalMode, count: $goalCount, showTimer: $showTimer, showCardsLearned: $showCardsLearned, ascending: $ascending, currentView: $currentView, killView: $killView)
                .environment(authManager)
            case .DecksView:
                DecksView(currentView: $currentView, bindedLanguage: $bindedLanguage, killView: $killView, prevView: $prevView, name: $name) // including language because this view will call deckRowView which cruciallly must have the authority to change the binded language to what the user selects
            case .GetSuggestions:
                GetSuggestions(
                    showingAlert: $showingAlert,
                    alertMessage: $alertMessage,
                    generatedSentence: $generatedSentence,
                    currentView: $currentView,
                    alertTitle: $alertTitle,
                    language: $bindedLanguage,
                    inputLanguage: $inputLanguage, translationLanguage: $translationLanguage, front: $front, back: $back
                    
                )
            case .CardListView:
                CardListView(
                    databaseManager: $databaseManager,
                    language: $bindedLanguage,
                    selectedCard: $selectedCard, translationLanguage: $translationLanguage, currentView: $currentView, front: $front, back: $back, killView: $killView)
                .environment(authManager)
            case .CreateOrGetSuggestionsView:
                CreateOrGetSuggestionsView(currentView: $currentView, language: $bindedLanguage, inputLanguage: $inputLanguage, translationLanguage: $translationLanguage, front: $front, back: $back)
            case .EditDecksView:
                EditDecksView(databaseManager: $databaseManager, language: $bindedLanguage, currentView: $currentView, killView: $killView)
            case .CardCreateView:
                CardCreateView(
                    databaseManager: $databaseManager,
                    front: $front,
                    translationLanguage: $translationLanguage,
                    inputLanguage: $inputLanguage,
                    showingAlert: $showingAlert,
                    alertMessage: $alertMessage,
                    alertTitle: $alertTitle,
                    currentView: $currentView,
                    language: $bindedLanguage,
                    prevView: $prevView,
                    killView: $killView
                )
            case .EditCardView:
                EditCardView(
                    databaseManager: $databaseManager,
                    front: $front,
                    back: $back,
                    translationLanguage: $translationLanguage,
                    inputLanguage: $inputLanguage,
                    showingAlert: $showingAlert,
                    alertTitle: $alertTitle,
                    alertMessage: $alertMessage,
                    currentView: $currentView,
                    language: $bindedLanguage,
                    existingCard: $selectedCard,
                    deleteCardAlert: $deleteCardAlert
                )
            case .PracticeViews:
                
                
                PracticeViews(cardUndoManager: $cardUndoManager, cardsTilReset: $cardsTilReset, language: $bindedLanguage, alertMessage: $alertMessage, alertTitle: $alertTitle, showingAlert: $showingAlert, showingAlertWithUndo: $showingAlertWithUndo, currentView: $currentView, selectedCard: $selectedCard, showTimer: $showTimer, mode: $goalMode, count: $goalCount, showCardsLearned: $showCardsLearned, ascending: $ascending, alreadyReachedGoal: $alreadyReachedGoal, cardIDs: $cardIDs)
                    .environmentObject(timerManager)
                
            case .BlackScreenView:
                BlackScreenView(currentView: $currentView, language: $bindedLanguage, killView: $killView)
            case .RefreshScreen:
                RefreshScreen(currentView: $currentView, killView: $killView)
            case .PracticeTimerView:
                PracticeTimerView(currentView: $currentView, mode: $goalMode, count: $goalCount, showTimer: $showTimer, language: $bindedLanguage, showCardsLearned: $showCardsLearned, ascending: $ascending)
                    .environmentObject(timerManager)
            case .Back:
                RefreshScreen(currentView: $currentView, killView: $killView) // just a temp thing cause it will change right away on onChangeOf
            case .GoalReached:
                GoalReached(name: $name, goalMode: $goalMode, count: $goalCount, language: $bindedLanguage, killView: $killView, currentView: $currentView, alreadyReachedGoal: $alreadyReachedGoal, cardIDs:  $cardIDs)
            
            case .CertificateGalleryView:
                CertificateGalleryView(certificate: $certificate, currentView: $currentView)
            case .PastCertificateView:
                PastCertificate(certificate: $certificate, killView: $killView, currentView: $currentView)
            }
        }
        .sheet(isPresented: $showEditCardModular) {
            EditCardView(
                databaseManager: $databaseManager,
                front: $front,
                back: $back,
                translationLanguage: $translationLanguage,
                inputLanguage: $inputLanguage,
                showingAlert: $showingAlert,
                alertTitle: $alertTitle,
                alertMessage: $alertMessage,
                currentView: $currentView,
                language: $bindedLanguage,
                existingCard: $selectedCard,
                deleteCardAlert: $deleteCardAlert
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"), action: {
                    
                    showingAlert = false
                    alertTitle = ""
                    alertMessage = "Something went wrong"
                })
            )
        }
        
        
        
        
        .alert(isPresented: $deleteCardAlert) {
            Alert(
                title: Text("Are you sure you want to delete this card?"),
                message: Text("This action cannot be undone."),
                primaryButton: .cancel(Text("Go back")),
                secondaryButton: .destructive(Text("Delete"), action: {
                    databaseManager.deleteCard(deckName: bindedLanguage, deleteCard: selectedCard) { error in
                        if let error = error {
                            alertTitle = "Error"
                            alertMessage = "Unable to delete right now. Please try again later."
                            showingAlert = true
                        } else {
                            print("success")
                            currentView = .CardListView
                        }
                    }
                })
            )
        }
        .onChange(of: currentView) { oldView, newView in
            
            if currentView == .PracticeViews && killView == true{
                print("its our favorite error. lets kill the view")
                currentView = oldView
            }
            
            
            
            else if currentView != .Back {
                viewStack.append(newView)
                
                
                if oldView == .CreateAccountView && newView == .LoginView{
                    currentView = .DecksView
                }
                
                if currentView != .PracticeViews && currentView != .PracticeTimerView{
                    print(currentView, "setting view to kill!")
                    killView = true
                }
                if currentView == .EditCardView {
                    front = selectedCard.front
                    back = selectedCard.back
                    translationLanguage = bindedLanguage
                    
                }
                
                if currentView == .CardCreateView {
                    front = ""
                    back = ""
                    translationLanguage = bindedLanguage
                    
                }
                print("👀🏖 view changed to: ", currentView, "killview = ", killView)
            }
            else {
                killView = true
                
                viewStack.removeLast()
                if let lastView = viewStack.last {
                    if lastView == .PracticeViews{
                        killView = false
                    }
                    currentView = lastView
                }
                
                
            }
            
            
            
        }
        
        .onChange(of: killView) {
            print("\n\n🔫🔫🔫🔫🔫🔫🔫🔫 KILLLL VIEW", killView)
            print("kill view changed in ", currentView)
            
            
            
            
        }
        .onAppear{
            if authManager.user != nil {
                        currentView = .DecksView
                    } else {
                        currentView = .LoginView
                    }
        }
        .onChange(of: authManager.user) {
            print("\n\n👩🏻‍🦰👩🏻‍🦰👩🏻‍🦰 user changed")
            if authManager.user != nil {
                        currentView = .DecksView
                    } else {
                        currentView = .LoginView
                    }
            
            
            
            
        }
        
    }
}
        
        
 


enum ViewType {
    case LoginView, CreateAccountView, EditGoalScreen, DecksView, GetSuggestions, CardListView, CreateOrGetSuggestionsView, EditDecksView, CardCreateView, EditCardView, BlackScreenView, RefreshScreen, PracticeViews, PracticeTimerView, Back, GoalReached, CertificateGalleryView, PastCertificateView
}
//if showCardAlert {
//    Text("showing!!!!")
//        .font(.largeTitle)
////                    CardAlertView(
////                        title: alertName,
////                        message: alertDescription, onUndo: {
////                            print("Alert undone")
////                            offset = .zero
////                            showing = true
////                            showCardAlert = false
////                        },
////                        onDismiss: {
////                            print("Alert dismissed")
////                            showCardAlert = false
////                        }
////
////                    )
//    .zIndex(1)
//}

enum GoalMode: String{
    case Minutes = "Minutes"
       case  Cards = "Cards"
}

