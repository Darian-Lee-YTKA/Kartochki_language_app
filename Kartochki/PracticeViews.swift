//
//  PracticeViews.swift
//  Kartochki
//
//  Created by Darian Lee on 7/23/24.
//

import SwiftUI


struct PopupView: View {
    let emoji: String
    let direction: CardContentView.SwipeDirection
    @State private var swipeOffset: CGFloat = 0
    var body: some View {
        VStack {
            Text("Please swipe")
                .font(.headline)
                .foregroundColor(.white)
            Text(emoji)
                .font(.system(size: 50))
                .transition(transitionForDirection(direction))
                .offset(x: swipeOffset)
                                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
        }
        .onAppear {
            if direction == .left{
                swipeOffset = -50
            }
            else {
                swipeOffset = 50
            }
        }
        .frame(width: 250, height: 100)
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                .foregroundColor(.white)
                .shadow(radius: 10)
    }
        
    
    private func transitionForDirection(_ direction: CardContentView.SwipeDirection) -> AnyTransition {
        switch direction {
        case .left:
            return .move(edge: .trailing)
        case .right:
            return .move(edge: .leading)
        }
    }
}




struct CardContentView: View {
    let card: Card
    @Binding var userAnswer: String
    @Binding var isShowingAnswer: Bool
    @Binding var attributedAnswers: (AttributedString, AttributedString)
    @State private var showPlainAnswer: Bool = false
    @State private var showSwipeReminder = false
    @State private var swipeDirection: SwipeDirection? = nil
    @State private var noUserAnswer: Bool =  false
  
   

    enum SwipeDirection {
        case left, right
    }
    
    var body: some View {
        VStack {
            ScrollView {
                HStack(spacing: 0) {
                    Image("kartochkiWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 100)
                        .clipped()
                        .padding(15)
                   
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                
                VStack {
                    Text(card.front)
                    
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .bold()
                        .lineLimit(nil)
                        .padding(.horizontal, 5)
                        //.fixedSize(horizontal: false, vertical: true)
                        
                }
                
                
                
                TextField("Type answer", text: $userAnswer, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundStyle(.black)
                    .padding()
                
                Button(action: {
                    if userAnswer == "" ||  userAnswer == " " {
                        showPlainAnswer.toggle()
                        isShowingAnswer.toggle()
                        noUserAnswer = true
                        
                    }
                    else{
                        noUserAnswer = false
                        attributedAnswers = colorAnswer(correct: card.back.lowercased(), userAnswer: userAnswer.lowercased())
                        isShowingAnswer.toggle()
                    }
                    
                }) {
                    Text("Show answer")
                        .foregroundColor(.white)
                        .padding()
                }
                
                if isShowingAnswer {
                    if showPlainAnswer {
                        HStack {
                            Text(card.back)
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                            
                            if noUserAnswer == false{
                                Button(action: {
                                    showPlainAnswer.toggle()
                                }) {
                                    
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text(attributedAnswers.0)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 5)

                            HStack {
                                Text(attributedAnswers.1)
                                Button(action: {
                                    showPlainAnswer.toggle()
                                }) {
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                    
                    
                }
            }
            
            
            Spacer()
            
            HStack {
                HStack {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                    Text("incorrect")
                        .foregroundColor(.white)
                }
                .onLongPressGesture(minimumDuration: 0.1) {
                    swipeDirection = .left
                    showSwipeReminder.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSwipeReminder = false
                    }
                }
                .overlay(
                    Group {
                        if showSwipeReminder, swipeDirection == .left {
                            PopupView(emoji: "👈", direction: .left)
                                .transition(.opacity)
                                .animation(.easeInOut, value: showSwipeReminder)
                        }
                    }
                )
                
                Spacer()
                
                HStack {
                    Text("correct")
                        .foregroundColor(.white)
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                }
                .onLongPressGesture(minimumDuration: 0.1) {
                    swipeDirection = .right
                    showSwipeReminder.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSwipeReminder = false
                    }
                }
                .overlay(
                    Group {
                        if showSwipeReminder, swipeDirection == .right {
                            PopupView(emoji: "👉", direction: .right)
                                .transition(.opacity)
                                .animation(.easeInOut, value: showSwipeReminder)
                        }
                    }
                )
            }
            .padding()
        }
    }

    
    
    private func colorAnswer(correct: String, userAnswer: String) -> (AttributedString, AttributedString) {
        var attributedString1 = AttributedString()
        var attributedString2 = AttributedString()
        
        let lightGreen = Color(red: 0.6, green: 0.85, blue: 0.6)
        let lightRed = UIColor(red: 255/255, green: 153/255, blue: 153/255, alpha: 1.0)
        let blackBackground = UIColor.black
        let whiteForeground = UIColor.white

        
//        if userAnswer == ""{
//           attributedString2 =  AttributedString(correct)
//            attributedString2.foregroundColor = whiteForeground
//            attributedString2.backgroundColor = blackBackground
//            attributedString2.underlineStyle = .single
//            
//            
//
//            attributedString1 = AttributedString("")
//            
//            return (attributedString1, attributedString2)
//        }
        
        
        
        let correctArray = Array(correct)
        let userAnswerArray = Array(userAnswer)
        
        
        var dp = Array(repeating: Array(repeating: 0, count: userAnswerArray.count + 1), count: correctArray.count + 1)
        
        for i in 0..<correctArray.count {
            for j in 0..<userAnswerArray.count {
                if correctArray[i] == userAnswerArray[j] {
                    dp[i + 1][j + 1] = dp[i][j] + 1
                } else {
                    dp[i + 1][j + 1] = max(dp[i + 1][j], dp[i][j + 1])
                }
            }
        }
        print("☎️")
        print(dp)
        print(dp[correctArray.count - 1][userAnswerArray.count - 1])
        var i = correctArray.count
        var j = userAnswerArray.count
        print(correctArray)
        while i > 0 && j > 0 {
            print("\nstarting new loop")
            print(attributedString1)
            print(attributedString2)
            if correctArray[i - 1] == userAnswerArray[j - 1] {
                print("Match found at indices i:\(i - 1) and j:\(j - 1)")
                
                
                var attributedChar = AttributedString(String(correctArray[i - 1]))
                attributedChar.foregroundColor = lightGreen
                attributedChar.backgroundColor = blackBackground
                
                attributedString1.insert(attributedChar, at: attributedString1.startIndex)
                attributedString2.insert(attributedChar, at: attributedString2.startIndex)
                i -= 1
                j -= 1
            } else if dp[i - 1][j] >= dp[i][j - 1] {
                print("Mismatch or deletion case at indices i:\(i - 1) and j:\(j)")
               
                
//                var attributedChar1 = AttributedString(String(userAnswerArray[j - 1]))
//                attributedChar1.foregroundColor = lightRed
//                attributedChar1.backgroundColor = blackBackground
//                attributedString1.insert(attributedChar1, at: attributedString1.startIndex)
                
                
                var attributedChar2 = AttributedString(String(correctArray[i - 1]))
                attributedChar2.foregroundColor = whiteForeground
                attributedChar2.backgroundColor = blackBackground
                attributedChar2.underlineStyle = .single
                
                attributedString2.insert(attributedChar2, at: attributedString2.startIndex)
                
            
                //j -= 1
                i -= 1
            } else {
                print("Substitution or insertion case at indices i:\(i) and j:\(j - 1)")
               
                
                var attributedChar1 = AttributedString(String(userAnswerArray[j - 1]))
                attributedChar1.foregroundColor = lightRed
                attributedChar1.backgroundColor = blackBackground
                
//                var attributedChar2 = AttributedString("-")
//                attributedChar2.foregroundColor = whiteForeground
//                attributedChar2.backgroundColor = blackBackground
                //attributedChar2.underlineStyle = .single
                
                attributedString1.insert(attributedChar1, at: attributedString1.startIndex)
                //attributedString2.insert(attributedChar2, at: attributedString2.startIndex)
               
                j -= 1
            }
        }
        
        
        print("this is what the correct array looks like before we handle extra characters")
        print(correctArray)
        print(i)
        while i > 0 {
            print("☎️☎️☎️☎️☎️it happened")
            print(i)
            print(correctArray[i - 1])
            
            var attributedChar = AttributedString(String(correctArray[i - 1]))
            attributedChar.foregroundColor = whiteForeground
            attributedChar.backgroundColor = blackBackground
            attributedChar.underlineStyle = .single
            
            attributedString2.insert(attributedChar, at: attributedString2.startIndex)
            i -= 1
        }
        
     
        while j > 0 {
            print("☎️☎️☎️☎️☎️it happened")
            var attributedChar = AttributedString(String(userAnswerArray[j - 1]))
            attributedChar.foregroundColor = lightRed
            attributedChar.backgroundColor = blackBackground
            
            attributedString1.insert(attributedChar, at: attributedString1.startIndex)
            j -= 1
        }
        
        return (attributedString1, attributedString2)
    }
}
    


struct FlashCard: View {
    @State var databaseManager: DatabaseManager = DatabaseManager()
    private let swipeThreshold: Double = 100
    @State var offset: CGSize = .zero
    @State var userAnswer: String = ""
    @State var attributedAnswers: (AttributedString, AttributedString) = (AttributedString(), AttributedString())
    @State var isShowingAnswer: Bool = false
    @State private var showing: Bool = true
    @State var tempCard: Card? = nil
    @Binding var cardsTilReset: Int
    @State private var alertName: String = ""
    @State private var alertDescription: String = ""
    @State var wasCorrect: Bool = false
    var deckName: String
    var card: Card
    let cardColor: Color
    
  
    
    @State private var showCardAlert = false
    @Binding var cardUndoManager: CardUndoManager
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                ZStack {
                    if showing {
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(offset.width < 0 ? .red : .green)
                        
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(cardColor)
                            .shadow(color: .black, radius: 4, x: -0.5, y: 0.5)
                            .opacity(1 - abs(offset.width) / swipeThreshold)
                        
                        CardContentView(
                            card: card,
                            userAnswer: $userAnswer,
                            isShowingAnswer: $isShowingAnswer,
                            attributedAnswers: $attributedAnswers
                        )
                    }
                    
                    
                }
                
                .offset(offset)
                .gesture(DragGesture()
                    .onChanged { gesture in
                        let translation = gesture.translation
                        offset = translation
                    }
                    .onEnded { gesture in
                                            if gesture.translation.width > swipeThreshold {
                                                
                                                print("👉 Swiped right")
                                                tempCard = card
                                                wasCorrect = true
                                                cardUndoManager.correctCount += 1
                                                print("new cardstilreset: ", cardsTilReset)
                                                
                                                let newInfoDic = databaseManager.increaseInterval(oldInterval: card.oldInterval, oldDate: card.dueDate)
                                                
                                                guard let newDate = newInfoDic["Date"] as? Date,
                                                      let newOldInt = newInfoDic["Int"] as? Int else {
                                                    alertName = "Showing went wrong"
                                                    alertDescription = "Unable to set new date"
                                                    showCardAlert = true
                                                    return
                                                }
                                                
                                                cardsTilReset += 1
                                                tempCard?.dueDate = newDate
                                                print("new date \(newDate)")
                                                
                                                tempCard?.oldInterval = newOldInt
                                                guard var tempCard = tempCard else{
                                                    return
                                                }
                                                
                                                cardUndoManager.cardOnStack = cardUndoManager.cardOnStack + [tempCard]
                                                print(tempCard.dueDate)
                                                alertName = "Card marked as correct"
                                                alertDescription =  "This card will be shown again in \(newOldInt / 60 / 60 / 24) days"
                                                showCardAlert = true
                                                showing = false
                                                
                                            
                            
                        } else if gesture.translation.width < -swipeThreshold {
                            print("👈 Swiped left")
                            wasCorrect = false
                            cardUndoManager.cardOnStack =  cardUndoManager.cardOnStack + [card]
                            alertName = "Card marked as incorrect"
                            alertDescription = "This card will be reset to new."
                            tempCard = card
                            showCardAlert = true
                            
                            showing = false
                            cardsTilReset += 1
                        } else {
                            print("🚫 Swipe canceled")
                            withAnimation(.bouncy) {
                                offset = .zero
                            }
                        }
                    }
                )
                .opacity(3 - abs(offset.width) / swipeThreshold * 3)
                .rotationEffect(.degrees(offset.width / 20.0))
                .frame(width: 355, height: 620)
                .padding(.horizontal)
            }
        }
        if showCardAlert {
                    CardAlertView(
                        cardUndoManager : $cardUndoManager,
                        title: alertName,
                        message: alertDescription,
                        
                        onUndo: {
                            print("🚫🚫 Alert undone 🚫🚫")
                            offset = .zero
                            showing = true
                            if wasCorrect{
                                cardUndoManager.correctCount -= 1
                            }
                            cardUndoManager.cardOnStack.removeLast() // to remove the last one in the stack so we don't edit it twice
                            showCardAlert = false
                            
                        },
                        onDismiss: {
                            showCardAlert = false
                            
                            
                            print("Alert dismissed")
                            
                            
                            
                            //No longer updating cards individually
//                            if let updatedCard = tempCard {
//                                print("we are updating to be this card!!!!!!!!!", updatedCard)
//                                databaseManager.editCardInDeck(deckName: deckName, editedCard: updatedCard) { error in
//                                    if let error = error {
//                                        print(error.localizedDescription)
//                                        alertName = "Error"
//                                        alertDescription = error.localizedDescription
//                                        showCardAlert = true
//                                        
//                                    }
//                                    else {
//                                        showCardAlert = false
//                                        
//                                    }
//                                }
//                            }
                        }
                    )
                    .zIndex(1)
                }
            }
        }


@Observable
class CardUndoManager {

    var cardOnStack: [Card] = []
 
    var correctCount: Int = 0
    var viewChanged: Int = 0
}

struct CardAlertView: View {
    @Binding var cardUndoManager: CardUndoManager
  
    var title: String
    var message: String

    var onUndo: () -> Void
    var onDismiss: () -> Void

    @State private var undoClicked = false
    @State private var timeRemaining: CGFloat = 3.0
    let darkGrey = Color(red: 40/255, green: 40/255, blue: 40/255)
    var body: some View {
        VStack {
            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 4) { 
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white)

                    if !message.isEmpty {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }

                    HStack {
                        Button(action: {
                            undoClicked = true
                            onUndo()
                        }) {
                            Text("Undo")
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        Spacer()
                    }
                    .padding(.top, 1.8)
                    
                    ProgressView(value: max(0, min(timeRemaining, 1.8)), total: 1.8)
                        .progressViewStyle(LinearProgressViewStyle(tint: darkGrey))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        .padding(.top, 4)
                }
                .padding(8)
                .background(Color.black)
                .cornerRadius(6)
                .shadow(radius: 3)
                .frame(maxWidth: 150)
                .transition(.move(edge: .bottom))
                .onAppear {
                    startTimer()
                }

                Spacer()
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background(Color.clear)
        .onChange(of: cardUndoManager.cardOnStack) { oldCards, newCards in
            if oldCards != [] {
                print("🥶 card got changed 🥶")
                
                onDismiss()
                print("this is the stack")
                for card in cardUndoManager.cardOnStack{
                    print(card.front)
                }
            
            }
        }
        .onChange(of: cardUndoManager.viewChanged) { oldView, newView in
            print("force end due to screen change")
                onDismiss()
            
        }
        
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                timer.invalidate()
                if !undoClicked {
                    onDismiss()
                }
            }
        }
    }
}





struct PracticeViews: View {
    @Binding var cardUndoManager: CardUndoManager
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @EnvironmentObject var timerManager: TimerManager
    @State private var score: Int = 0
    @State var cardsLearned: String = "0"
    @State var goToEditGoalScreen: Bool = false
    @Binding var cardsTilReset: Int
    @State var currentCardIndex: Int = 9
   
    @State private var isDataProcessing: Bool = false
  
    //var resetVal = 0
   
    @State var showRefreshScreen: Bool = false
   
    @State private var showBlackScreen: Bool = false

    
    @Binding var language: String
    @Binding var alertMessage: String
    @Binding var alertTitle: String
    @Binding var showingAlert: Bool
    @Binding var showingAlertWithUndo: Bool
    @Binding var currentView: ViewType

    @Binding var selectedCard: Card
    
    @Binding var showTimer: Bool
    @Binding var mode: GoalMode
    @Binding var count: Int
    @Binding var showCardsLearned: Bool
    @Binding var ascending: Bool
    @Binding var alreadyReachedGoal: [String]
    @Binding var cardIDs: [String]
//    var customAlert: Alert {
//        Alert(
//            title: Text(alertMessage),
//            primaryButton: .default(Text("OK")),
//            secondaryButton: .cancel(Text("Undo"), action: {
//                offset = .zero
//            })
//        )
//    }
    
//    init(language: String, cardsTilReset: Binding<Int>) {
//            self.language = language
//            self._cardsTilReset = cardsTilReset
//
//
//
//        }
                
           
            
                
            
        
    let colorList: [Color] = [
        
        
        
 
        Color(red: 47/255, green: 79/255, blue: 79/255),  // (dark slate gray)
        Color(red: 40/255, green: 45/255, blue: 45/255),  // (very dark gray)
        Color(red: 69/255, green: 69/255, blue: 69/255),  // (gray)
        Color(red: 153/255, green: 61/255, blue: 108/255) // (deep pink/magenta tone)

    ]
    var body: some View {
        ZStack {
            
            Color.black.ignoresSafeArea()
            
            
            
            VStack {
                VStack{
                    VStack{
                        
                        
                        HStack {
                            Button(action: {
                                timerManager.stopTimer()
                                if (!isDataProcessing) {
                                    handleViewChange(newView: .DecksView)
                                }
                            }) {
                                Image(systemName: "arrow.left")
                                    .resizable()
                                    .frame(width: 28, height: 20)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                            Button(action: {
                                timerManager.stopTimer()
                                if (!isDataProcessing) {
                                    handleViewChange(newView: .CardListView)
                                }
                            }) {
                                Image(systemName: "mail.stack.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                            Button(action: {
                                print(currentCardIndex)
                                if databaseManager.currentBatch.count > 0 {
                                    selectedCard = databaseManager.currentBatch[min(currentCardIndex, databaseManager.currentBatch.count - 1)]
                                    print(selectedCard)
                                    handleViewChange(newView: .EditCardView)
                                }
                                
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                            Button(action: {
                                cardUndoManager.viewChanged += 1
                                handleViewChange(newView: .CardCreateView)
                            }) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                
                            }
                        }
                        .padding()
                        HStack{
                            if mode == GoalMode.Minutes  {
                                Text(timeString(from: timerManager.counter))
                                    .font(.system(size: 30, weight: .bold))
                            }
                            else {
                                if ascending == true{
                                    Text("Learned " + String(cardUndoManager.correctCount))
                                        .font(.system(size: 30, weight: .bold))
                                }
                                else{
                                    Text("Learned " + String(max(0, count - cardUndoManager.correctCount)))
                                        .font(.system(size: 30, weight: .bold))
                                }
                            }
                            
                            
                            Button(action: {
                                cardUndoManager.viewChanged += 1
                                currentView = .EditGoalScreen}
                            ){
                                Text("Edit goal")
                                    .foregroundColor(Color(red: 213/255, green: 121/255, blue: 168/255))
                            }
                        }
                        if (mode == GoalMode.Minutes && showCardsLearned) {
                            if ascending == true{
                                Text("Learned " + String(cardUndoManager.correctCount))
                                    .font(.system(size: 30, weight: .bold))
                            }
                            else{
                                Text("Learned " + String(max(0, count - cardUndoManager.correctCount)))
                                    .font(.system(size: 30, weight: .bold))
                            }
                        }
                        else if mode != GoalMode.Minutes && showTimer{
                            Text(timeString(from: timerManager.counter))
                        }
                    }
                        
                        
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                    
                }
                .frame(alignment: .top)
                
                VStack(alignment: .leading){
                    ZStack{
                        if !isDataProcessing{
                            DoneView(currentView: $currentView, cardUndoManager: $cardUndoManager, databaseManager: $databaseManager, language: $language)
                        }
                        ForEach(databaseManager.currentBatch.indices, id: \.self) { index in
                            FlashCard(cardsTilReset: $cardsTilReset, deckName: language, card: databaseManager.currentBatch[index], cardColor: colorList[index % colorList.count], cardUndoManager: $cardUndoManager)
                            //.rotationEffect(.degrees(Double(cards.count - 1 - index) * -0.5))
                            
                                .offset(x: CGFloat(3 * -(index % 6)), y: CGFloat(4 * index % 4))
                            
                            
                        }
                        
                        
                        
                        
                        Spacer()
                    }
                }
                .onAppear {
                   
                    print("appeared to have appeared \n :)")
                    print("Current view: \(currentView)")
                    
                        print("not kill view")
                        print("loading cards")
                        isDataProcessing = true
                        databaseManager.fetchDueCards(limit: 10, language: language) { error in
                            isDataProcessing = false
                            if let error = error {
                                print("Error fetching cards: \(error.localizedDescription)")
                            } else {
                                print("Successfully fetched cards")
                                cardsTilReset = 0 
                                
                            }
                        }
//                        databaseManager.getGoalPreferences(language: language){ error in
//                            if let error = error{
//                                print(error.localizedDescription)
//                            }
//                            else{
//                                mode = databaseManager.goalPreference.goalMode
//                                count = databaseManager.goalPreference.count
//                                showTimer = databaseManager.goalPreference.showTimer
//                                
//                            }
                        
                        
                    
                   
                }
                
                .onChange(of: cardsTilReset) {
                    
                            
                            if cardsTilReset % 10 == 0 && cardsTilReset > 0 {
                                print("♠️♠️ cardsTilReset: \(cardsTilReset)")
                                print("showing black screen")
                                cardUndoManager.viewChanged += 1
                                handleViewChange(newView: .BlackScreenView)
                                
                            }
                        
                }
                
                .onChange(of: cardUndoManager.cardOnStack) {
                    print(cardUndoManager.cardOnStack.count)
                    if databaseManager.currentBatch.count != 10{
                        print("notify me of this oddity")
                        currentCardIndex = databaseManager.currentBatch.count - 1 - cardUndoManager.cardOnStack.count
                    }
                    currentCardIndex = 9 - cardUndoManager.cardOnStack.count // the logic is, the cards are displayed such that the first one in the batch is displayed last
                    //  if we have swiped on 3 cards, that means we swiped on the cards at indexes 9, 8, and 7 so the current showing card is at index 6
                    // thus 9 - cards swipped
                    
                        
                }
                .onChange(of: timerManager.hasReachedGoal) {
                    if !(alreadyReachedGoal.contains(language)){
                        print("time goalReached!")
                        
                        handleViewChange(newView: .GoalReached)
                    }
                }
                .onChange(of: cardUndoManager.correctCount) { oldVal, newVal in
                    if newVal == count && mode == .Cards {
                        if !(alreadyReachedGoal.contains(language)){
                            print("card goalReached!")
                            handleViewChange(newView: .GoalReached)
                        }
                    }
                        
                }
                
                .onReceive(timerManager.$counter) { newCounter in
                    if newCounter == 0 {
     
                        
                    }
                }
               

            }
        }
    }
   
        private func timeString(from seconds: Int) -> String {
            let minutes = seconds / 60
            let seconds = seconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    func handleViewChange(newView: ViewType) {
        print("handeling view change")
        if isDataProcessing == false { // make sure we arent fetching cards
            print("data is not currently proccessing")
            isDataProcessing = true
            databaseManager.editBatchOfCards(deckName: language, editedCards: cardUndoManager.cardOnStack) {
                error in
                isDataProcessing = false
                if let error = error{
                    print(error)
                    
                }
                else {
                    print("successful batch edit")
                    print(cardUndoManager.cardOnStack)
                    for card in cardUndoManager.cardOnStack {
                        cardIDs = cardIDs + [card.id]
                    }
                    
                    cardUndoManager.cardOnStack = []
                    print(cardUndoManager.cardOnStack)
                    
                    currentView = newView
                }
            }
        }
    }
        
        
    
}

struct DoneView: View {
    @Binding var currentView: ViewType
    @Binding var cardUndoManager: CardUndoManager
    @Binding var databaseManager:DatabaseManager
    @Binding var language: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.black)
                .frame(width: 355, height: 650)
                .padding(.horizontal)

            VStack {
                Text("Looks like you're done!")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(maxWidth: 300)
                    .lineLimit(nil)
                    .padding()

                Button(action: {
                    cardUndoManager.viewChanged += 1
                    databaseManager.editBatchOfCards(deckName: language, editedCards: cardUndoManager.cardOnStack) {
                        error in
                        
                        if let error = error{
                            print(error)
                            
                        }
                        else {
                            print("successful batch edit")
                            print(cardUndoManager.cardOnStack)
                            cardUndoManager.cardOnStack = []
                            print(cardUndoManager.cardOnStack)
                            
                            currentView = .RefreshScreen
                        }
                        
                    }
                }) {
                    Text("Manual Refresh 🔄")
                        .foregroundStyle(.white)
                        .frame(maxWidth: 100)
                        .lineLimit(nil)
                }
            }
        }
    }
}


struct BlackScreenView: View {

    @State private var currentRotation: Double = 0
    @State private var yOffset: CGFloat = -UIScreen.main.bounds.height / 2
    @State private var opacity: Double = 1.0
    @State private var timer: Timer? = nil
    @State private var message: [String] = ["", ""]
    @State private var color: Color = Color(red: 153/255, green: 61/255, blue: 108/255)
    @State private var type: Int = 1
    @State private var emoji: String = "😄"
    
    @Binding var currentView: ViewType
    @Binding var language: String
    @Binding var killView: Bool
    var body: some View {
        ZStack {
            color.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text(message[0])
                    .font(.title)
                    .foregroundColor(.white)
                Text(message[1])
                    .font(.caption)
                    .foregroundColor(.white)
                    
                Text("You earned 5 more points")
                    .font(.headline)
                    .foregroundColor(.white)
                
                if type == 1 {
                    
                    Image("smilingkar1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(currentRotation))
                        .offset(y: yOffset)
                        .opacity(opacity)
                        .onAppear {
                            startAnimation()
                        }
                }
                
                if type == 2 {
                    ZStack {
                    
                    
                    
                    Text(ModivationScreenDictionarys().languagesWithCulturalAndFlagEmojis[language] ?? "😄")
                        .font(.system(size: 80))
                        .padding(.vertical)
                        .rotationEffect(.degrees(currentRotation))
                        .offset(y: yOffset)
                        .opacity(opacity)
                }
                    .onAppear {
                        startAnimation()
                    }
            }
                
                   
                if type == 3 {
                    
                    ZStack {
                                
                                Circle()
                                    .stroke(Color.black, lineWidth: 6)
                                    //.background(Circle().fill(Color.white))
                                    .padding(8)
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(currentRotation))
                                    .offset(y: yOffset)
                                    .opacity(opacity)


                                
                        Text(emoji)
                                    .font(.system(size: 90))
                                    //.padding(.vertical)
                                    .rotationEffect(.degrees(currentRotation))
                                    .offset(y: yOffset)
                                    .opacity(opacity)
                            }
                            .onAppear {
                                startAnimation()
                            }
                }
                
                
                Spacer()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        
        .onAppear {
            setupMessage()
        }
    }
    
    private func setupMessage() {
        let dictionaryOptions = [
            ModivationScreenDictionarys().languagesWithMotivationalPhrases1,
            ModivationScreenDictionarys().languagesWithMotivationalPhrases2,
            ModivationScreenDictionarys().languagesWithMotivationalPhrases3
        ]
        
        if let dict = dictionaryOptions.randomElement()?[language] {
            message = dict
        }
        let possibleTypes = [1, 1, 2, 3]
        type = possibleTypes.randomElement() ?? 1
        if type == 3{
            emoji = ["😄", "☺️", "😌", "😊", "😃", "😁"].randomElement() ?? "😄"
            color = [Color.black, Color(red: 255/255, green: 99/255, blue: 71/255), Color(red: 70/255, green: 130/255, blue: 180/255)].randomElement() ?? Color.black
        }
        
        else if type == 2{
            
            color = Color.black
        }
        else if type == 1 {
            let colors = [
                
                Color(red: 235/255, green: 85/255, blue: 160/255), // Hot Pink
                
                
                Color(red: 123/255, green: 63/255, blue: 123/255),  // Muted Dark Orchid
                //
                Color(red: 70/255, green: 130/255, blue: 180/255),  // Steel Blue
                
                Color(red: 255/255, green: 99/255, blue: 71/255),  // Tomato
                Color(red: 153/255, green: 61/255, blue: 108/255),
                
                
            ]
            if let randomColor = colors.randomElement() {
                print(randomColor)
                color = randomColor
            }
            
        }
        
        
        
        
    }
    
    private func startAnimation() {
        let rotationSequence: [Double] = [0, 10, 20, 30, 45, 55, 45, 30, 20, 10, 0, -10, -20, -30, -45, -55, -45, -30, -20, -10, 0]
        var index = 0
        
        
        withAnimation(Animation.easeInOut(duration: 0.6)) {
            yOffset = 0
        }
        
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { _ in
                currentRotation = rotationSequence[index]
                index = (index + 1) % rotationSequence.count
                
                // Stop spinning and fade out after one cycle of rotation
                if index == 0 {
                    timer?.invalidate()
                    withAnimation(Animation.easeInOut(duration: 0.6)) {
                        yOffset = UIScreen.main.bounds.height / 2
                        opacity = 0.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        killView = false
                        currentView = .PracticeViews
                    }
                }
            }
        }
    }
}








extension String {
    subscript(_ range: Range<Int>) -> Substring {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return self[start..<end]
    }

    subscript(_ range: ClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return self[start...end]
    }
}



class ModivationScreenDictionarys{
    let languagesWithMotivationalPhrases1: [String: [String]] = [
        "Japanese": ["よくやった！", "(Good job!)"],
        "Spanish": ["¡Bien hecho!", "(Well done!)"],
        "Chinese": ["做得好！", "(Good job!)"],
        "Arabic": ["أحسنت!", "(Well done!)"],
        "Russian": ["Молодец!", "(Good job!)"],
        "Korean": ["잘했어요!", "(Well done!)"],
        "German": ["Gut gemacht!", "(Well done!)"],
        "French": ["Bon travail!", "(Good job!)"],
        "Turkish": ["Aferin!", "(Well done!)"],
        "Italian": ["Bel lavoro!", "(Good job!)"],
        "Hindi": ["शाबाश!", "(Well done!)"],
        "Urdu": ["شاباش!", "(Well done!)"],
        "Vietnamese": ["Làm tốt lắm!", "(Good job!)"],
        "Polish": ["Dobra robota!", "(Good job!)"],
        "Persian": ["آفرین!", "(Well done!)"],
        "Ukrainian": ["Молодець!", "(Good job!)"],
        "Portuguese": ["Bom trabalho!", "(Good job!)"]
    ]
    
    let languagesWithMotivationalPhrases2: [String: [String]] = [
        "Japanese": ["おめでとうございます！", "(Congratulations!)"],
        "Spanish": ["¡Eres muy inteligente!", "(You're so smart!)"],
        "Chinese": ["干得漂亮！", "(Well done!)"],
        "Arabic": ["ممتاز!", "(Excellent!)"],
        "Russian": ["Браво!", "(Bravo!)"],
        "Korean": ["계속 그렇게 하세요!", "(Keep it up!)"],
        "German": ["Herzlichen Glückwunsch!", "(Congratulations!)"],
        "French": ["C'est formidable!", "(That's wonderful!)"],
        "Turkish": ["Harikasın!", "(You're great!)"],
        "Italian": ["Complimenti!", "(Congratulations!)"],
        "Hindi": ["बहुत बढ़िया!", "(Very good!)"],
        "Urdu": ["کمال ہے!", "(Wonderful!)"],
        "Vietnamese": ["Tuyệt vời!", "(Excellent!)"],
        "Polish": ["Gratulacje!", "(Congratulations!)"],
        "Persian": ["خیلی عالی!", "(Very great!)"],
        "Ukrainian": ["Відмінно!", "(Excellent!)"],
        "Portuguese": ["Parabéns!", "(Congratulations!)"]
    ]
    
    let languagesWithMotivationalPhrases3: [String: [String]] = [
        "Japanese": ["君はスーパースターだ！", "(You're a superstar!)"],
        "Spanish": ["¡Eres una estrella!", "(You're a star!)"],
        "Chinese": ["你是个超级明星！", "(You're a superstar!)"],
        "Arabic": ["أنت نجم حقيقي!", "(You're a real star!)"],
        "Russian": ["Ты суперзвезда!", "(You're a superstar!)"],
        "Korean": ["넌 진짜 슈퍼스타야!", "(You're a real superstar!)"],
        "German": ["Du bist ein Superstar!", "(You're a superstar!)"],
        "French": ["Tu es une vraie star!", "(You're a star!)"],
        "Turkish": ["Sen tam bir yıldızsın!", "(You're a real star!)"],
        "Italian": ["Sei una vera star!", "(You're a real star!)"],
        "Hindi": ["तुम एक स्टार हो!", "(You're a star!)"],
        "Urdu": ["آپ واقعی سپر اسٹار ہیں!", "(You're truly a superstar!)"],
        "Vietnamese": ["Bạn là một ngôi sao sáng!", "(You're a shining star!)"],
        "Polish": ["Jesteś gwiazdą!", "(You're a star!)"],
        "Persian": ["تو یه ستاره‌ای!", "(You're a star!)"],
        "Ukrainian": ["Ти справжня зірка!", "(You're a real star!)"],
        "Portuguese": ["Você é uma estrela de verdade!", "(You're a real star!)"]
    ]
    let languagesWithCulturalAndFlagEmojis: [String: String] = [
        "Japanese": "🍣",
        "Spanish": "💃",
        "Chinese": "🐉",
        "Arabic": "🕌",
        "Russian": "🪆",
        "Korean": "🥢",
        "German": "🍺",
        "French": "🥖",
        "Turkish": "☕️",
        "Italian": "🍕",
        "Hindi": "🪷",
        "Urdu": "🏏",
        "Vietnamese": "🍜",
        "Polish": "🕍",
        "Persian": "🐆",
        "Ukrainian": "🥟",
        "Portuguese": "🏖️"
    ]
    
    
}


struct RefreshScreen: View {

    @State private var animateText: Bool = false
    @Binding var currentView: ViewType
    @Binding var killView: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Text("Refreshing 🌱")
                .foregroundColor(.white)
                .font(.system(size: 30, weight: .bold))
                .scaleEffect(animateText ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: animateText
                )
                .onAppear {
                    animateText = true
                }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                killView = false
                currentView = .PracticeViews
            }
        }
        
    }
}


struct PracticeTimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Binding var currentView: ViewType
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @Binding var mode: GoalMode
    @Binding var count: Int
    @Binding var showTimer: Bool
    @Binding var language: String
    @Binding var showCardsLearned: Bool
    @Binding var ascending: Bool
    
    @State private var isLoading: Bool = true // State to track loading status

    let pink = Color(red: 255/255, green: 192/255, blue: 203/255) // Define pink color

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: pink))
                        .scaleEffect(2.0) // Make the progress wheel a bit bigger
                    Text("Loading...")
                        .foregroundColor(pink)
                        .font(.headline)
                        .padding(.top, 8)
                }
            } else {
                Text("Starting timer")
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            print("PracticeTimerView started")
            databaseManager.getGoalPreferences(language: language) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Inside PracticeTimerView, found: ", databaseManager.goalPreference)
                    mode = databaseManager.goalPreference.goalMode
                    count = databaseManager.goalPreference.count
                    showTimer = databaseManager.goalPreference.showTimer
                    showCardsLearned = databaseManager.goalPreference.showCardsLearned
                    ascending = databaseManager.goalPreference.ascending
                    
                    timerManager.changeSettings(goalTime: count, acsending: ascending, mode: mode)
                    timerManager.resetTimer()
                    currentView = .PracticeViews
                }
                isLoading = false // Hide loading spinner after data is fetched
            }
        }
    }
}
