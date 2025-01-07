//
//  DatabaseManager.swift
//  Kartochki
//
//  Created by Darian Lee on 6/5/24.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseCore
import SwiftUI
import FirebaseStorage
import PhotosUI

@Observable
class DatabaseManager {
    let database: Firestore
    var languages: [String] = []
    var name: String = ""
    var decks: [DeckData] = []
    var nonLanguages: [String] = []
    var goal: [String: Int] = [:]
    var AllCards: [Card] = []
    var dueCards: [Card] = []
    var certificates: [Certificate] = []
    var goalPreference: GoalPreference = GoalPreference(goalMode: .Minutes, count: 15, showTimer: true, showCardsLearned: true, ascending: false, language: "Spanish")
    
    var dueCounts: [String: Int] = [
        "Japanese": 0,
        "Spanish": 0,
        "Chinese": 0,
        "Arabic": 0,
        "Russian": 0,
        "Korean": 0,
        "German": 0,
        "French": 0,
        "Turkish": 0,
        "Italian": 0,
        "Hindi": 0,
        "Urdu": 0,
        "Vietnamese": 0,
        "Polish": 0,
        "Persian": 0,
        "Ukrainian": 0,
        "Portuguese": 0,
        "Swahili": 0
    ]
    var currentBatch: [Card] = []
    
    init(){
        
        self.database = Firestore.firestore()
        
    }
    
    func getWelcomeMessage(language: String) -> String{
        let languageTranslationsWelcome: [String: String] = [
            "Japanese": "ようこそ",
            "Spanish": "Bienvenido",
            "Chinese": "欢迎",
            "Arabic": "أهلا بك",
            "Russian": "Добро пожаловать",
            "Korean": "환영합니다",
            "German": "Willkommen",
            "French": "Bienvenue",
            "Turkish": "Hoş geldiniz",
            "Italian": "Benvenuto",
            "Hindi": "स्वागत है",
            "Urdu": "خوش آمدید",
            "Vietnamese": "Chào mừng",
            "Polish": "Witamy",
            "Persian": "خوش آمدید",
            "Ukrainian": "Ласкаво просимо",
            "Portuguese": "Bem-vindo",
            "Swahili": "Karibu tena"
        ]
        
        let languageTranslationsGoodToSeeYou: [String: String] = [
            "Japanese": "お会いできて嬉しいです",
            "Spanish": "Me alegra verlo",
            "Chinese": "见到您很高兴",
            "Arabic": "سعدت برؤيتك",
            "Russian": "Рад вас видеть",
            "Korean": "반갑습니다",
            "German": "Schön Sie zu sehen",
            "French": "Content de vous voir",
            "Turkish": "Sizi görmek güzel",
            "Italian": "Felice di vederla",
            "Hindi": "आपसे मिलकर अच्छा लगा",
            "Urdu": "آپ سے مل کر خوشی ہوئی",
            "Vietnamese": "Rất vui được gặp bạn",
            "Polish": "Miło cię widzieć",
            "Persian": "از دیدنتان خوشبختم",
            "Ukrainian": "Радий вас бачити",
            "Portuguese": "Bom vê-lo",
            "Swahili": "Mambo"
        ]
        
        guard let messageType = [languageTranslationsGoodToSeeYou, languageTranslationsWelcome].randomElement() else{
            return "Welcome"
        }
        
        guard let message = messageType[language] else{
            print("no message found")
            return "Welcome"
        }
        print("🕉️🕉️🕉️ this is the message 🕉️🕉️🕉️", message)
        return message
    }
    
    
    
    func getLanguages(completion: @escaping () -> Void) {
        let allLanguages = ["Arabic", "Chinese", "French", "German", "Hindi", "Italian", "Japanese", "Korean", "Persian", "Polish", "Portuguese", "Russian", "Spanish", "Turkish", "Ukrainian", "Urdu", "Vietnamese", "Swahili"]
        
        print("running get languages")
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            completion()
            return
        }
        
        if let email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        
        print("userID")

   
        var languagesFetched = false
        var personalInfoFetched = false

        func checkCompletion() {
            if languagesFetched && personalInfoFetched {
                completion()
            }
        }


        database.collection("Users").document(userID).collection("Languages")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    languagesFetched = true
                    checkCompletion()
                    return
                }
                
                var languages: [String] = []
                for document in documents {
                    let data = document.data()
                    if let language = data["language"] as? String {
                        print("we found this language: ")
                        print(language)
                        languages.append(language)
                    }
                }
                
                self.languages = languages
                self.nonLanguages = allLanguages.filter { !languages.contains($0) }
                languagesFetched = true
                checkCompletion()
            }
        
 
        database.collection("Users").document(userID).collection("PersonalInfo")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching personal info: \(String(describing: error))")
                    personalInfoFetched = true
                    checkCompletion()
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    if let name = data["name"] as? String {
                        print("we found this name: ")
                        print(name)
                        self.name = name
                    }
                }
                
                personalInfoFetched = true
                checkCompletion()
            }
    }
    
    func getOverdueCards(deckName: String){
        print("🚔🚔 getting overdue 🚔🚔")
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        
        database.collection("Users").document(userID).collection("Decks").document(deckName).collection("Cards")
        
            .addSnapshotListener { querySnapshot, error in
                
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                var dueCards: [Card] = []
                for document in documents {
                    let data = document.data()
                    
                    guard let date = self.asDate(data["dueDate"]) else {
                        print("failed to parse date")
                        return
                    }
                    let cardStartOfDay = calendar.startOfDay(for: date)
                    
                    if cardStartOfDay <= startOfDay{
                        if let front = data["front"] as? String,
                           let back = data["back"] as? String,
                           let id = data["id"] as? String,
                           let oldInt = data["oldInterval"] as? Int {
                            
                            
                            let card = Card(front: front, back: back, dueDate: date, id: id, oldInterval: oldInt)
                            print(card)
                            dueCards.append(card)
                        } else {
                            print("Failed to parse some data")
                        }
                        
                        
                    }
                    
                }
                
                print("we are setting these cards as dueCards")
                print(dueCards)
                self.dueCards = dueCards
                
            }
        
        self.dueCounts[deckName] = dueCards.count
        
        
        
        
    }
    
    
    private func setDueCount(count: Int, language: String, completion: @escaping (Error?) -> Void) {
        
        self.dueCounts[language] = count
        //        getCertainDeckData(deck: language) { result in
        //            switch result {
        //            case .success(var currentDeck):
        //
        //                currentDeck.dueCount = count
        //
        //
        //                let deckDataDict = self.deckToDic(deck: currentDeck)
        //
        //
        //                guard let userID = Auth.auth().currentUser?.uid else {
        //                    print("No user ID found inside func setDueCount()")
        //                    completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"]))
        //                    return
        //                }
        //
        //
        //                self.database.collection("Users").document(userID).collection("DeckDatas").document(language).setData(deckDataDict) { error in
        //                    if let error = error {
        //                        print("Error adding document: \(error.localizedDescription)")
        //                        completion(error)
        //                    } else {
        //                        print("Count changed to: \(deckDataDict["dueCount"] ?? 0)")
        //                        completion(nil)
        //                    }
        //                }
        //
        //            case .failure(let error):
        //                print("Error fetching DeckData: \(error.localizedDescription)")
        //                completion(error)
        //            }
        //        }
    }
    
    
    
    private func getCertainDeckData(deck: String, completion: @escaping (Result<DeckData, Error>) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        
        
        
        database.collection("Users").document(userID).collection("DeckDatas").document(deck).getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                print("Document does not exist")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                return
            }
            
            if let name = data["name"] as? String,
               let count = data["count"] as? Int,
               let dueCount = data["dueCount"] as? Int {
                let deckData = DeckData(name: name, count: count, dueCount: dueCount)
                completion(.success(deckData))
            } else {
                print("Error parsing document data")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error parsing document data"])))
            }
        }
    }
    
    func getDeckData(){
        
        
        print("getting deck datas")
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        database.collection("Users").document(userID).collection("DeckDatas")
        
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                
                var deckDatas: [DeckData] = []
                
                for document in documents {
                    let data = document.data()
                    
                    if let name = data["name"] as? String,
                       let count = data["count"] as? Int,
                       let dueCount = data["dueCount"] as? Int{
                        //due count isnt really used anymore
                        
                        let deck = DeckData(name: name, count: count, dueCount: dueCount)
                        deckDatas.append(deck)
                    }
                }
                
                self.decks = deckDatas
                
            }
        
        database.collection("Users").document(userID).collection("PersonalInfo")
        
            .addSnapshotListener { querySnapshot, error in
                
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    if let name = data["name"] as? String{
                        self.name = name
                    }
                }
                
                
                
            }
    }
    
    func setLanguages(languages: [String], completion: @escaping (Error?) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        print("auth.auth!", userID)
        //var languageDict: [[String:String]] = []
        for language in languages{
            let tempDict = ["language": language]
            self.database.collection("Users").document(userID).collection("Languages").document(language).setData(tempDict) { error in
                print(error?.localizedDescription)
                completion(error)
            }
            
        }
        
        getLanguages{
            
        }
    }
    
    var isUploading = false

    func saveCertificate(goalMessage: String, userMessage: String, cardIDs: [String], deckName: String, photo: PhotosPickerItem?, date: String, completion: @escaping (Error?) -> Void) {
        print("🛟 called save certificate 🛟")
        guard var userID = Auth.auth().currentUser?.uid else {
            print("No user ID found inside func saveCertificate()")
            completion(NSError(domain: "saveCertificate", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user ID found"]))
            return
        }
        guard let email = Auth.auth().currentUser?.email else {
            print("no email")
            return
            
        }
       
       
        guard !isUploading else {
            print("Upload already in progress")
            completion(NSError(domain: "saveCertificate", code: -2, userInfo: [NSLocalizedDescriptionKey: "Upload already in progress"]))
            return
        }

        isUploading = true

        let certificateData: [String: Any] = [
            "goalMessage": goalMessage,
            "userMessage": userMessage,
            "cardIDs" : cardIDs,
            "deckName" : deckName,
            "date" : date
            
        ]

        if let photo = photo {
            print("photo found")
            let imageID = UUID().uuidString
            let storageRef = Storage.storage().reference().child("certificates/\(userID)/\(imageID).jpg")
            
            Task {
                defer { isUploading = false }
                print(isUploading)

                do {
                    if let data = try await photo.loadTransferable(type: Data.self) {
                        print(data)
                        if let image = UIImage(data: data),
                           let jpegData = image.jpegData(compressionQuality: 0.1) {
                            storageRef.putData(jpegData, metadata: nil) { metadata, error in
                                if let error = error {
                                    print(metadata)
                                    print("Failed to upload image: \(error.localizedDescription)")
                                    completion(error)
                                    return
                                }
                                
                                storageRef.downloadURL { url, error in
                                    if let error = error {
                                        print(url)
                                        print("Failed to get download URL: \(error.localizedDescription)")
                                        completion(error)
                                        return
                                    }
                                    
                                    guard let imageUrl = url?.absoluteString else {
                                        print("Failed to get image URL")
                                        completion(NSError(domain: "saveCertificate", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get image URL"]))
                                        return
                                    }
                                    
                                    var updatedCertificateData = certificateData
                                    print(updatedCertificateData)
                                    
                                    updatedCertificateData["photoUrl"] = imageUrl
                                    print(updatedCertificateData)
                                    let userId = String((Auth.auth().currentUser?.email ?? "").prefix(5) + (Auth.auth().currentUser?.uid ?? ""))  //need to fix later
                                     
                                    Firestore.firestore().collection("Users").document(userId).collection("Certificate").document(Date().description).setData(updatedCertificateData) { error in
                                        if let error = error {
                                            print("Failed to save certificate: \(error.localizedDescription)")
                                            completion(error)
                                        } else {
                                            completion(nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("Failed to load image data: \(error.localizedDescription)")
                    completion(error)
                }
            }
        } else {
        
            Firestore.firestore().collection("Users").document(userID).collection("Certificate").document(Date().description).setData(certificateData) { error in
                self.isUploading = false
                if let error = error {
                    print("Failed to save certificate: \(error.localizedDescription)")
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func fetchCertificates(completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user ID found inside func fetchCertificates()")
            completion(NSError(domain: "fetchCertificates", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user ID found"]))
            return
        }
        let userId = String((Auth.auth().currentUser?.email ?? "").prefix(5) + (Auth.auth().currentUser?.uid ?? ""))  //need to fix later
        print("running fetchCertificates")
        Firestore.firestore().collection("Users").document(userId).collection("Certificate").getDocuments { querySnapshot, error in
            if let error = error {
                print("Failed to fetch certificates: \(error.localizedDescription)")
                completion(error)
                return
            }
            print(querySnapshot?.documents)
            guard let documents = querySnapshot?.documents else {
                print("No certificates found")
                completion(nil)
                return
            }
            
            var certificates: [Certificate] = []
            
            for document in documents {
                let data = document.data()
                print(data)
                if let goalMessage = data["goalMessage"] as? String {
                    print("Found goalMessage: \(goalMessage)")
                } else {
                    print("Failed to parse goalMessage")
                }
                
                if let userMessage = data["userMessage"] as? String {
                    print("Found userMessage: \(userMessage)")
                } else {
                    print("Failed to parse userMessage")
                }
                
                if let cardIDs = data["cardIDs"] as? [String] {
                    print("Found cardIDs: \(cardIDs)")
                } else {
                    print("Failed to parse cardIDs")
                }
                
                if let deckName = data["deckName"] as? String {
                    print("Found deckName: \(deckName)")
                } else {
                    print("Failed to parse deckName")
                }
                
                let photoUrl = data["photoUrl"] as? String
                if let photoUrl = photoUrl {
                    print("Found photoUrl: \(photoUrl)")
                } else {
                    print("No photoUrl found or failed to parse")
                }
                if let date = data["date"] {
                    print("Found date: \(date)")
                } else {
                    print("No date found or failed to parse")
                }
                
                if let goalMessage = data["goalMessage"] as? String,
                   let userMessage = data["userMessage"] as? String,
                   let cardIDs = data["cardIDs"] as? [String],
                   let deckName = data["deckName"] as? String,
                let date = data["date"] as? String {
                    let certificate = Certificate(goalMessage: goalMessage, userMessage: userMessage, photoUrl: photoUrl, cardIDs: cardIDs, deckName: deckName, date: date)
                    certificates.append(certificate)
                    
                    
                }
               
                
            }
            certificates.sort {
                guard let date1 = self.dateFromString($0.date), let date2 = self.dateFromString($1.date) else { return false }
                        return date1 > date2
                    }
            print("THESE ARE THE FINAL CERTIFICATES \(certificates)")
            self.certificates = certificates
            completion(nil)
        }
    }
    private func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"  // Match the date format of your string
        return dateFormatter.date(from: dateString)
    }
//        if var email = Auth.auth().currentUser?.email {
//            userID = email.prefix(5) + userID
//        }
//        print("auth.auth!", userID)
//        
//        let tempdict = ["goalMessage": goalMessage, "userMessage": userMessage, photo: PhotosPickerItem]
//        self.database.collection("Users").document(userID).collection("Certificate").document(Date()).setData(tempDict) { error in
//            print(error?.localizedDescription)
//            completion(error)
//            
//            
//            
//            
//        }
//    }
    
    
    func createDeck(language: String, completion: @escaping (Error?) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        self.changeGoalPreference(language: language, newPreference: GoalPreference(goalMode: .Minutes, count: 15, showTimer: true, showCardsLearned: true, ascending: false, language: language)) { error in
            if let error = error{
                print(error.localizedDescription)
            }
        }
        
        let translations: [String: String] = [
            "Japanese": "これは例のカードです。",
            "Spanish": "Esta es una tarjeta de ejemplo.",
            "Chinese": "这是一张示例卡片。",
            "Arabic": "هذه بطاقة مثال.",
            "Russian": "Это примерная карта.",
            "Korean": "이것은 예제 카드입니다.",
            "German": "Dies ist eine Beispielkarte.",
            "French": "Ceci est une carte d'exemple.",
            "Turkish": "Bu bir örnek karttır.",
            "Italian": "Questa è una carta di esempio.",
            "Hindi": "यह एक उदाहरण कार्ड है।",
            "Urdu": "یہ ایک مثال کارڈ ہے۔",
            "Vietnamese": "Đây là một thẻ ví dụ.",
            "Polish": "To jest przykładowa karta.",
            "Persian": "این یک کارت نمونه است.",
            "Ukrainian": "Це приклад картки.",
            "Portuguese": "Este é um cartão de exemplo.",
            "Swahili": "hii ni kadi ya mfano"
            
        ]
        
        guard let translation = translations[language] else {
            print("Translation not found for language: \(language)")
            completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Translation not found"]))
            return
        }
        
        let card: [String: Any] = cardToDic(front: "This is an example card", back: translation, dueDate: nil, id: "new", oldInterval: 0)
        
        guard let cardID = card["id"] as? String else {
            print("Card has no ID")
            completion(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Card has no ID"]))
            return
        }
        
        
        
        self.database.collection("Users").document(userID).collection("Decks").document(language).collection("Cards").document(cardID).setData(card) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(card["front"] ?? "not found")")
            }
            completion(error)
        }
        
        let deckDataDict = deckToDic(deck: DeckData(name: language, count: 1, dueCount: 1))
        
        
        self.database.collection("Users").document(userID).collection("DeckDatas").document(language).setData(deckDataDict) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(deckDataDict["count"] ?? 0)")
            }
            completion(error)
        }
    }
    
    private func increaseDeckCount(language: String, completion: @escaping (Error?) -> Void) {
        getDeckData()
        print("➕ running increase deck count ➕")
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        print(self.decks)
        guard var currentDeck = self.decks.first(where: { $0.name == language }) as? DeckData else{
            print("➕ no current deck ➕")
            return
        }
        currentDeck.count = currentDeck.count + 1
        let deckDataDict = deckToDic(deck: currentDeck)
        self.database.collection("Users").document(userID).collection("DeckDatas").document(language).setData(deckDataDict) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("count changed to: \(deckDataDict["count"] ?? 0)")
            }
            completion(error)
        }
        getDeckData()
        
    }
    
    
    func getCardsWithCertainIDs(language: String, IDs: [String], completion: @escaping ([Card]?, Error?) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            completion(nil, NSError(domain: "getCardsWithCertainIDs", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user ID found"]))
            return
        }
        
        if let email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }

       
        database.collection("Users").document(userID).collection("Decks").document(language).collection("Cards")
            .whereField("id", in: IDs).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found for given IDs")
                completion(nil, nil)
                return
            }
            
            var cards: [Card] = []
            
            for document in documents {
                let data = document.data()
                
                if let front = data["front"] as? String,
                   let back = data["back"] as? String,
                   let id = data["id"] as? String,
                   let oldInt = data["oldInterval"] as? Int,
                   let date = self.asDate(data["dueDate"]) {
                    
                    let card = Card(front: front, back: back, dueDate: date, id: id, oldInterval: oldInt)
                    cards.append(card)
                } else {
                    print("Failed to parse some data for document ID: \(document.documentID)")
                }
            }
            
            
            completion(cards, nil)
        }
    }
        
        
    
    
    private func decreaseDeckCount(language: String, completion: @escaping (Error?) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        guard var currentDeck = self.decks.first(where: { $0.name == language }) as? DeckData else{
            return
        }
        currentDeck.count = max(currentDeck.count - 1, 0)
        let deckDataDict = deckToDic(deck: currentDeck)
        self.database.collection("Users").document(userID).collection("DeckDatas").document(language).setData(deckDataDict) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("count changed to: \(deckDataDict["count"] ?? 0)")
            }
            completion(error)
        }
        
    }
    
    
    
    
    private func cardToDic(front: String, back: String, dueDate: Date?, id: String, oldInterval: Int) -> [String: Any]{
        var cardId = id
        var cardDueDate = dueDate
        if id == "new"{
            cardId = UUID().uuidString
            cardDueDate = Date()
        }
        
        guard let cardDueDate = cardDueDate else{
            print("☎️ error. About to save card with no due date attached ☎️")
            return ["front": front, "back":back, "dueDate": Date(), "id": cardId, "oldInterval": oldInterval]
        }
        
        return ["front": front, "back":back, "dueDate": cardDueDate, "id": cardId, "oldInterval": oldInterval]
        
        
    }
    
    private func deckToDic(deck: DeckData) -> [String : Any]{
        let name = deck.name
        let count = deck.count
        let dueCount = deck.dueCount
        return ["name": name, "count": count, "dueCount": dueCount]
    }
    
    
    func initializeNewUser(languages: [String], name: String, email: String, completion: @escaping (Error?) -> Void){
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        self.database.collection("Users").document(userID).collection("PersonalInfo").document("name").setData(["name": name, "email": email]) { error in
            print(error?.localizedDescription)
            completion(error)
        }
        
        self.setLanguages(languages: languages) { error in
            if let error = error {
                print("Error adding room: \(error.localizedDescription)")
            }
        }
        for language in languages{
            self.createDeck(language: language){ error in
                if let error = error {
                    print("Error adding room: \(error.localizedDescription)")
                }
            }
            
            
        }
        
        
    }
    
   
    
    
    
    
    
    
    
    
    func addCardToDeck(deckName: String, card:Card, completion: @escaping (Error?) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        
        let card = cardToDic(front: card.front, back: card.back, dueDate: card.dueDate, id: card.id, oldInterval: card.oldInterval)
        
        
        guard let cardID = card["id"] as? String else{
            print("card has no id")
            return
        }
        
        self.database.collection("Users").document(userID).collection("Decks").document(deckName).collection("Cards").document(cardID).setData(card) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("card added with name: \(card["front"] ?? "not found")")
                self.increaseDeckCount(language: deckName) { error in
                    if let error = error {
                        
                        print("Error: \(error.localizedDescription)")
                    } else {
                        
                        print("Deck count increased successfully.")
                        //self.getDeckData()
                    }
                }
                //self.fetchDueNumber(language: deckName)
                
                
                
            }
            completion(error)
        }
        
    }
    
    func getAllCardsInDeck(deckName: String){
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        
        print("running get all cards in deck жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж")
        database.collection("Users").document(userID).collection("Decks").document(deckName).collection("Cards")
        
            .addSnapshotListener { querySnapshot, error in
                
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                var cards: [Card] = []
                for document in documents {
                    let data = document.data()
                    
                    if let front = data["front"] as? String,
                       let back = data["back"] as? String,
                       let id = data["id"] as? String,
                       let oldInt = data["oldInterval"] as? Int,
                       let date = self.asDate(data["dueDate"]) {
                        
                        
                        let card = Card(front: front, back: back, dueDate: date, id: id, oldInterval: oldInt)
                        
                        cards.append(card)
                    } else {
                        print("Failed to parse some data")
                    }
                    
                    
                }
                
                
                self.AllCards = cards
                
            }
    }
    
    private func asDate(_ value: Any?) -> Date? {
        
        if let timestamp = value as? Timestamp {
            
            
            return timestamp.dateValue()
        } else if let dateString = value as? String {
            let dateFormatter = ISO8601DateFormatter()
            return dateFormatter.date(from: dateString)
        }
        return nil
    }
    
    func editCardInDeck(deckName: String, editedCard:Card, completion: @escaping (Error?) -> Void) {
        print("✍🏻📝✍🏻📝 editing card ✍🏻📝✍🏻📝")
        print(editedCard.oldInterval)
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        
        let card = cardToDic(front: editedCard.front, back: editedCard.back, dueDate: editedCard.dueDate, id: editedCard.id, oldInterval: editedCard.oldInterval)
        
        
        guard let cardID = card["id"] as? String else{
            print("card has no id")
            return
        }
        
        self.database.collection("Users").document(userID).collection("Decks").document(deckName).collection("Cards").document(cardID).setData(card) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("card edited with name: \(card["front"] ?? "not found")")
                
                
            }
            completion(error)
        }
        
    }
    
    
    func editBatchOfCards(deckName: String, editedCards: [Card], completion: @escaping (Error?) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("No user ID found inside func editBatchOfCards()")
            return
        }
        
        if let email = Auth.auth().currentUser?.email {
            userID = String(email.prefix(5)) + userID
        }
        
        let batch = self.database.batch()
        let userDeckRef = self.database.collection("Users").document(userID).collection("Decks").document(deckName)
        
        for editedCard in editedCards {
            let cardData = cardToDic(front: editedCard.front, back: editedCard.back, dueDate: editedCard.dueDate, id: editedCard.id, oldInterval: editedCard.oldInterval)
            
            guard let cardID = cardData["id"] as? String else {
                print(editedCard.front, " Card has no ID")
                continue
            }
            
            let cardRef = userDeckRef.collection("Cards").document(cardID)
            batch.setData(cardData, forDocument: cardRef)
        }
        
        batch.commit { error in
            if let error = error {
                print("Error committing batch: \(error.localizedDescription)")
            } else {
                print("Batch edit successful for \(editedCards.count) cards")
            }
            completion(error)
        }
    }
    
    
    func deleteCard(deckName: String, deleteCard:Card, completion: @escaping (Error?) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        print("")
        print("😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈Running delete card😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈")
        print("")
        let cardID = deleteCard.id
        
        self.database.collection("Users").document(userID).collection("Decks").document(deckName).collection("Cards").document(cardID).delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                print("Card deleted with front: \(deleteCard.front)")
                print("card id " + deleteCard.id)
                self.decreaseDeckCount(language: deckName) { error in
                    if let error = error {
                        
                        print("Error: \(error.localizedDescription)")
                    } else {
                        
                        print("Deck count decreased successfully.")
                    }
                }
                
            }
            completion(error)
        }
    }
    
    
    
    
    func deleteLanguageAndDeck(language: String, completion: @escaping (Error?) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        print("auth.auth!", userID)
        
        database.collection("Users").document(userID).collection("Languages").document(language)
            .delete { error in
                if let error = error {
                    print("Error removing language from Firestore:", error.localizedDescription)
                    completion(error)
                } else {
                    print("Language removed from Firestore successfully")
                    completion(nil)
                }
            }
        
        self.database.collection("Users").document(userID).collection("DeckDatas").document(language)
            .delete { error in
                if let error = error {
                    print("Error removing deck data from Firestore:", error.localizedDescription)
                    completion(error)
                } else {
                    print("Deck Data removed from Firestore successfully")
                    completion(nil)
                }
            }
        
        
        deleteAllCards(deckName: language) { error in
            if let error = error {
                print("Error deleting all cards: \(error.localizedDescription)")
            } else {
                print("All cards deleted successfully.")
            }
        }
        
        self.database.collection("Users").document(userID).collection("Decks").document(language)
            .delete { error in
                if let error = error {
                    print("Error removing WHOLE deck from Firestore:", error.localizedDescription)
                    completion(error)
                } else {
                    print("WHOLE Deck removed from Firestore successfully")
                    completion(nil)
                }
            }
        self.dueCounts[language] = 0
        getDeckData()
    }
    
    
    
    func increaseInterval(oldInterval: Int, oldDate: Date) -> [String: Any] {
        print("🕰️🕰️🕰️ running increase interval 🕰️🕰️🕰️")
        var newInterval: Int
        
        if oldInterval == 0 {
            newInterval = 24 * 60 * 60 * 2
        } else if oldInterval == 24 * 60 * 60 * 2 {
            newInterval = 24 * 60 * 60 * 10 
        } else {
            newInterval = oldInterval * 2
        }
        print("oldDate: \(oldDate)")
        print("newInterval: \(newInterval)")
        print("🗓️ oldDate: \(oldDate)")
        let newDate = Calendar.current.date(byAdding: .second, value: newInterval, to: Date()) ?? oldDate
        if newDate == oldDate {
            print("⚠️ newDate is the same as oldDate. Check the calculation.")
        } else {
            print("✅ newDate calculated correctly: \(newDate)")
        }
        
        return ["Date": newDate, "Int" : newInterval]
    }
    
    
    
    
    func deleteAllDocumentsInCollection(collectionPath: String, batchSize: Int = 100, completion: @escaping (Error?) -> Void) {
        let collectionRef = self.database.collection(collectionPath)
        
        func deleteBatch(query: Query, completion: @escaping (Error?) -> Void) {
            query.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {
                    completion(error)
                    return
                }
                
                guard !snapshot.isEmpty else {
                    
                    completion(nil)
                    return
                }
                
                let batch = self.database.batch()
                snapshot.documents.forEach { batch.deleteDocument($0.reference) }
                
                batch.commit { batchError in
                    if let batchError = batchError {
                        completion(batchError)
                        return
                    }
                    
                    
                    deleteBatch(query: query, completion: completion)
                }
            }
        }
        
        let initialQuery = collectionRef.limit(to: batchSize)
        deleteBatch(query: initialQuery, completion: completion)
    }
    
    
    func deleteAllCards(deckName: String, completion: @escaping (Error?) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        if var email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        
        let collectionPath = "Users/\(userID)/Decks/\(deckName)/Cards"
        
        deleteAllDocumentsInCollection(collectionPath: collectionPath) { error in
            if let error = error {
                print("Error deleting all cards: \(error.localizedDescription)")
            } else {
                print("All cards deleted successfully.")
            }
            completion(error)
        }
    }
    
    
    
    func fetchDueCards(limit: Int = 5, language: String, completion: @escaping (Error?) -> Void) {
        print("\n🟪🟪🟪🟪🟪🟪 let's fetch some cards, shall we 🟪🟪🟪🟪🟪🟪")
        guard var userID = Auth.auth().currentUser?.uid else {
            print("No user ID found inside func fetchDueCards()")
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"]))
            return
        }
        if let email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }
        let todayTimestamp = Timestamp(date: Date())
        print(todayTimestamp)
        
        database.collection("Users").document(userID).collection("Decks").document(language).collection("Cards")
            .whereField("dueDate", isLessThanOrEqualTo: todayTimestamp)
            .order(by: "dueDate")
            .limit(to: limit)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    completion(error)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found"]))
                    return
                }
                
                var cards: [Card] = []
                for document in documents {
                    let data = document.data()
                    
                    if let front = data["front"] as? String,
                       let back = data["back"] as? String,
                       let id = data["id"] as? String,
                       let oldInt = data["oldInterval"] as? Int,
                       let date = self.asDate(data["dueDate"]) {
                        
                        let card = Card(front: front, back: back, dueDate: date, id: id, oldInterval: oldInt)
                        
                        cards.append(card)
                    } else {
                        print("Failed to parse some data")
                    }
                }
                
                self.currentBatch = cards
                completion(nil) 
            }
    }
    
    func fetchDueNumber(language: String) {
        Task {
            do {
                guard var userID = Auth.auth().currentUser?.uid else {
                    print("no user id found inside func getLanguages()")
                    
                    return
                }
                if var email = Auth.auth().currentUser?.email {
                    userID = email.prefix(5) + userID
                }
                let todayTimestamp = Timestamp(date: Date())
                let countQuery = database.collection("Users").document(userID).collection("Decks").document(language).collection("Cards")
                    .whereField("dueDate", isLessThanOrEqualTo: todayTimestamp)
                
                let snapshot = try await countQuery.count.getAggregation(source: .server)
                let count = snapshot.count
                print("Total due cards count: \(count) for language \(language)")
                
                self.dueCounts[language] = Int(count)
                
            } catch {
                print("Error fetching due number: \(error.localizedDescription)")
            }
        }
    }
    
    func getGoalPreferences(language: String, completion: @escaping (Error?) -> Void) {
        guard var userID = Auth.auth().currentUser?.uid else {
            print("No user ID found inside func getGoalPreferences()")
            completion(NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user ID found"])) // Handle the error case
            return
        }

        if let email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }

        database.collection("Users").document(userID).collection("GoalPreferences").document(language)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(String(describing: error))")
                    completion(error) // Pass the error to the completion handler
                    return
                }

                if let data = document.data() {
                    let goalModeString = data["goalMode"] as? String
                                   let goalMode: GoalMode?
                                   if let modeString = goalModeString {
                                       goalMode = GoalMode(rawValue: modeString)
                                   } else {
                                       goalMode = nil
                                   }
                                   
                                   if let goalMode = goalMode,
                                      let count = data["count"] as? Int,
                                      let showTimer = data["showTimer"] as? Bool,
                                      let goalLanguage = data["language"] as? String,
                                        let showCardsLearned = data["showCardsLearned"] as? Bool,
                                        let ascending = data["ascending"] as? Bool {
                                       self.goalPreference = GoalPreference(goalMode: goalMode, count: count, showTimer: showTimer, showCardsLearned: showCardsLearned, ascending: ascending, language: goalLanguage)
                                       completion(nil)
                                   } else {
                        
                        completion(NSError(domain: "Firestore", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to parse goal data"]))
                        if let goalMode = data["goalMode"] as? GoalMode {
                            print("goalMode: \(goalMode)")
                        } else {
                            print("Error: 'goalMode' is missing or not of type GoalMode")
                        }
                        
                        if let count = data["count"] as? Int {
                            print("count: \(count)")
                        } else {
                            print("Error: 'count' is missing or not of type Int")
                            
                        }
                        
                        if let showTimer = data["showTimer"] as? Bool {
                            print("showTimer: \(showTimer)")
                        } else {
                            print("Error: 'showTimer' is missing or not of type Bool")
                        }
                        
                        if let goalLanguage = data["language"] as? String {
                            print("goalLanguage: \(goalLanguage)")
                        }
                    }
                } else {
                    print("Unable to set goal data: ", document.data() ?? "none found")
                    completion(NSError(domain: "Firestore", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data found in document"]))
                }
            }
    }

    func changeGoalPreference(language: String, newPreference: GoalPreference, completion: @escaping (Error?) -> Void) {
        print("✍🏻📝✍🏻📝 Changing goal preferences ✍🏻📝✍🏻📝")

        guard var userID = Auth.auth().currentUser?.uid else {
            print("No user ID found inside func changeGoalPreference()")
            return
        }

        if let email = Auth.auth().currentUser?.email {
            userID = email.prefix(5) + userID
        }

        let goalDict: [String: Any] = [
            "goalMode": newPreference.goalMode.rawValue,
            "count": newPreference.count,
            "showTimer": newPreference.showTimer,
            "showCardsLearned": newPreference.showCardsLearned,
            "ascending" : newPreference.ascending,
            "language": language
        ]

        database.collection("Users").document(userID).collection("GoalPreferences").document(language).setData(goalDict) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Preferences set successfully: ", newPreference)
            }
            completion(error)
        }
    }
        
    
    
    func fetchDueNumbersForAllLanguages(languages: [String], completion: @escaping (Error?) -> Void) {
        print(languages)
        Task {
            guard let user = Auth.auth().currentUser else {
                print("No user id found inside func fetchDueNumbersForAllLanguages()")
                completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user found"]))
                return
            }
            
            var userID = user.uid
            if let email = user.email {
                userID = email.prefix(5) + userID
            }
            
            let todayTimestamp = Timestamp(date: Date())
            
            await withTaskGroup(of: (String, Int?).self) { group in
                for language in languages {
                    let userIDCopy = userID
                    group.addTask {
                        let countQuery = self.database.collection("Users").document(userIDCopy).collection("Decks").document(language).collection("Cards")
                            .whereField("dueDate", isLessThanOrEqualTo: todayTimestamp)
                        
                        do {
                            let snapshot = try await countQuery.count.getAggregation(source: .server)
                            let count = snapshot.count
                            print("Total due cards count: \(count) for language \(language)")
                            return (language, Int(count))
                        } catch {
                            print("Error fetching due number for language \(language): \(error.localizedDescription)")
                            return (language, nil)
                        }
                    }
                }
                
                var hasError = false
                for await (language, count) in group {
                    if let count = count {
                        self.dueCounts[language] = count
                        print("We found this count for this language: \(language), \(count)")
                    } else {
                        self.dueCounts[language] = -1
                        hasError = true
                    }
                }
                
                if hasError {
                    completion(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Some languages could not be fetched."]))
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func add50CardsForDeveloperTest(language: String) {
        getDeckData()
        guard let user = Auth.auth().currentUser else {
            print("No user id found inside func getLanguages()")
            return
        }
        print("get cheat cards for \(language)")
        var userID = user.uid
        if let email = user.email {
            userID = email.prefix(5) + userID
        }
        var cards: [[String:Any]] = []
        if language == "Swahili"{
            print("addinfg 50 cards")
            cards = [
                ["front": "House", "back": "Nyumba", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Dog", "back": "Mbwa", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Cat", "back": "Paka", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Book", "back": "Kitabu", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Chair", "back": "Kiti", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Table", "back": "Meza", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Car", "back": "Gari", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Tree", "back": "Mti", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Water", "back": "Maji", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Food", "back": "Chakula", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Sun", "back": "Jua", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Moon", "back": "Mwezi", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Day", "back": "Siku", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Night", "back": "Usiku", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Friend", "back": "Rafiki", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Family", "back": "Familia", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "School", "back": "Shule", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Teacher", "back": "Mwalimu", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Student", "back": "Mwanafunzi", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Street", "back": "Mtaa", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Market", "back": "Soko", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "City", "back": "Jiji", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Country", "back": "Nchi", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Girl", "back": "Msichana", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Boy", "back": "Mvulana", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Woman", "back": "Mwanamke", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Man", "back": "Mwanaume", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Child", "back": "Mtoto", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Sister", "back": "Dada", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Brother", "back": "Kaka", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "You", "back": "Wewe", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "We", "back": "Sisi", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "They", "back": "Wao", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Game", "back": "Mchezo", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Music", "back": "Muziki", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Song", "back": "Wimbo", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Picture", "back": "Picha", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Window", "back": "Dirisha", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Door", "back": "Mlango", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Bed", "back": "Kitanda", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Pillow", "back": "Mto", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Blanket", "back": "Blanketi", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Shoes", "back": "Viatu", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Clothes", "back": "Mavazi", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "Hat", "back": "Kofia", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0]
            ]
        }
        else if language == "Turkish" {
            cards = [
                ["front": "argument", "back": "tartışma", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "candidate", "back": "aday", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "challenge", "back": "meydan okuma", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "communication", "back": "iletişim", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "community", "back": "toplum", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "contract", "back": "sözleşme", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "conversation", "back": "sohbet", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "decision", "back": "karar", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "development", "back": "gelişim", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "discussion", "back": "tartışma", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "education", "back": "eğitim", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "example", "back": "örnek", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "experience", "back": "deneyim", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "explanation", "back": "açıklama", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "freedom", "back": "özgürlük", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "impression", "back": "izlenim", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "information", "back": "bilgi", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "inspiration", "back": "ilham", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "interview", "back": "mülakat", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "knowledge", "back": "bilgi", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "law", "back": "hukuk", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "literature", "back": "edebiyat", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "maintenance", "back": "bakım", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "method", "back": "yöntem", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "monitor", "back": "gösterge", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "network", "back": "ağ", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "option", "back": "seçenek", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "organization", "back": "organizasyon", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "participant", "back": "katılımcı", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "performance", "back": "performans", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "reduction", "back": "azalma", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "research", "back": "araştırma", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "responsibility", "back": "sorumluluk", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "schedule", "back": "program", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "solution", "back": "çözüm", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "theory", "back": "teori", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "tradition", "back": "gelenek", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "trend", "back": "trend", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "universe", "back": "evren", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "variable", "back": "değişken", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "volunteer", "back": "gönüllü", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "welfare", "back": "refah", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                ["front": "workshop", "back": "atölye", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0]
            ]
        }
       else if language == "Russian" {
            cards = [
            ["front": "to squeeze out", "back": "выдавить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to shove", "back": "впихнуть", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to get weathered", "back": "обветриться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to humiliate", "back": "унижать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to exhaust", "back": "исчерпать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to attack", "back": "нападать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to retreat", "back": "отступать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to encircle", "back": "окружить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to suppress", "back": "подавить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to infiltrate", "back": "просочиться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to evacuate", "back": "эвакуировать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to conquer", "back": "завоевать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to fortify", "back": "укрепить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to storm", "back": "штурмовать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to reinforce", "back": "усилить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to neutralize", "back": "нейтрализовать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to barricade", "back": "баррикадировать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to besiege", "back": "осадить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to blockade", "back": "блокировать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to disperse", "back": "рассеять", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to overthrow", "back": "свергнуть", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to devastate", "back": "разорить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to withdraw", "back": "вывести", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to loot", "back": "грабить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to sabotage", "back": "саботировать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to detain", "back": "задержать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to eradicate", "back": "искоренить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to smuggle", "back": "контрабандировать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0], ["front": "to drip", "back": "капать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to flow", "back": "течь", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to pour", "back": "лить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to spill", "back": "разлить", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to splash", "back": "брызгать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to seep", "back": "просачиваться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to trickle", "back": "струиться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to gush", "back": "хлестать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to bubble", "back": "пузыриться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to evaporate", "back": "испаряться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to condense", "back": "конденсироваться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to leak", "back": "утекать", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to swirl", "back": "вихриться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to soak", "back": "впитываться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to diffuse", "back": "распространяться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to saturate", "back": "насыщаться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to drain", "back": "сочиться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to spray", "back": "распылять", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to overflow", "back": "переливаться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to ooze", "back": "сочиться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
            ["front": "to gush out", "back": "извергаться", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0]]
            
        }
        else {
            cards =
                [
                   
                        ["front": "advice", "back": "consejo", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "agreement", "back": "acuerdo", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "analysis", "back": "análisis", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "application", "back": "aplicación", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "approach", "back": "enfoque", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "argument", "back": "argumento", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "benefit", "back": "beneficio", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "challenge", "back": "desafío", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "concept", "back": "concepto", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "connection", "back": "conexión", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "contrast", "back": "contraste", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "courage", "back": "valor", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "decision", "back": "decisión", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "definition", "back": "definición", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "development", "back": "desarrollo", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "experience", "back": "experiencia", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "expression", "back": "expresión", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "freedom", "back": "libertad", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "goal", "back": "objetivo", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "impression", "back": "impresión", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "information", "back": "información", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "inspiration", "back": "inspiración", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "knowledge", "back": "conocimiento", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "literature", "back": "literatura", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "method", "back": "método", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "opinion", "back": "opinión", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "possibility", "back": "posibilidad", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "process", "back": "proceso", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "progress", "back": "progreso", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "quality", "back": "calidad", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "reaction", "back": "reacción", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "relation", "back": "relación", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "resource", "back": "recurso", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "response", "back": "respuesta", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "situation", "back": "situación", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "strategy", "back": "estrategia", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "solution", "back": "solución", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "support", "back": "apoyo", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "technique", "back": "técnica", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                        ["front": "theory", "back": "teoría", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "I shook my head and smiled in regret", "back": "Sacudí la cabeza y sonreí arrepentido", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The scent of roses lingers", "back": "El aroma de las rosas perdura", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 60*60*24],
                    ["front": "The rain fell softly as I sat there, wondering if he was still mad", "back": "La lluvia cayó suavemente mientras me sentaba allí, preguntándome si todavía estaba enojado", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The fragrance of jasmine filled the night air", "back": "La fragancia del jazmín llenaba el aire nocturno", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The dusk wrapped the world in its purple veil", "back": "El crepúsculo envolvió al mundo en su velo púrpura", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": (60*60*24)*3],
                    ["front": "Her laughter danced in the air and conquered my heart", "back": "Su risa bailó en el aire y conquistó mi corazón", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "Her presence was a melody that lingered long after the music had stopped", "back": "Su presencia era una melodía que persistía mucho después de que la música se había detenido", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The sunset painted the sky with hues of fire", "back": "El atardecer pintó el cielo con tonos de fuego", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": (60*60*24)*2],
                    ["front": "Relief flowed through me like cold rain", "back": "El alivio fluyó a través de mí como lluvia fría", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "She invaded my mind and conquered my imagination with her commanding gaze", "back": "Ella invadió mi mente y conquistó mi imaginación con su mirada dominante", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "I held her to my chest and stroked her head as she fell asleep", "back": "La sostuve contra mi pecho y le acaricié la cabeza mientras se dormía", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The stars whispered secrets only the night could understand", "back": "Las estrellas susurraban secretos que solo la noche podía entender", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "Her gaze was a silent storm, powerful and captivating", "back": "Su mirada era una tormenta silenciosa, poderosa y cautivadora", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "Her words were like warm sunshine after a storm", "back": "Sus palabras eran como el cálido sol después de una tormenta", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": (60*60*24)],
                    ["front": "Her touch filled my brain with glitter", "back": "Su toque llenó mi cerebro de brillo", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "He wrapped me in his dark embrace", "back": "Él me envolvió en su oscuro abrazo", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "She fiddled with her key as she lied", "back": "Jugó con su llave mientras mentía", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The moonlight kissed her cheeks as she smiled, and all I wanted was to smile back", "back": "La luz de la luna besó sus mejillas mientras sonreía, y todo lo que quería era devolverle la sonrisa", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The guilt spilled over like a wave crashing through my body, causing me to almost lose balance", "back": "La culpa se derramó como una ola rompiendo a través de mi cuerpo, haciéndome casi perder el equilibrio", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": (60*60*24)*5],
                    ["front": "The echoes of our laughter still lingered in the corners of the empty room", "back": "Los ecos de nuestra risa aún persistían en los rincones de la habitación vacía", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The moon cast a silver path across the dark waters", "back": "La luna proyectó un sendero plateado a través de las oscuras aguas", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": (60*60*24)],
                    ["front": "Did I deserve to have my trust betrayed?", "back": "¿Merecía que me traicionaran la confianza?", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "Her little fingers grasped and squeezed my hand", "back": "Sus pequeños dedos agarraron y apretaron mi mano", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The first snow of winter fell gently, covering the world in a blanket of purity", "back": "La primera nieve del invierno caía suavemente, cubriendo el mundo con una manta de pureza", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "Her eyes were full of regret", "back": "Sus ojos estaban llenos de arrepentimiento", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "Her words were like soft rain", "back": "Sus palabras eran como lluvia suave", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": (60*60*24)],
                    ["front": "I will never betray you.", "back": "Nunca te traicionaré", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "Maybe she was bothered by my silence, because she turned and left", "back": "Tal vez le molestó mi silencio, porque se dio la vuelta y se fue", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "Her laughter was like the first rays of dawn", "back": "Su risa era como los primeros rayos del alba", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The ocean yelled and spat as if annoyed by our presence", "back": "El océano gritó y escupió como molesto por nuestra presencia", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0],
                    ["front": "The autumn leaves danced to the rhythm of the wind", "back": "Las hojas otoñales bailaban al ritmo del viento", "dueDate": Date(), "id": UUID().uuidString, "oldInterval": 0]
                ]
}
        
        
        for card in cards {
            
            self.database.collection("Users").document(userID).collection("Decks").document(language).collection("Cards").document(card["id"] as! String).setData(card) {  error in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                } else {
                    print("Document successfully added!")
                    
                }
            }
            
        }
        guard var currentDeck = self.decks.first(where: { $0.name == language }) else{
            print("➕ no current deck ➕")
            return
        }
        currentDeck.count = currentDeck.count + cards.count
        let deckDataDict = deckToDic(deck: currentDeck)
        self.database.collection("Users").document(userID).collection("DeckDatas").document(language).setData(deckDataDict) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("count changed to: \(deckDataDict["count"] ?? 0)")
            }
            
        }
     
        
    }
    
}






// I decided to make this struct not contain cards since it is going to be fetched so often and it would be too expensive to fetch all the cards every time we just want to get the number
struct DeckData: Equatable, Hashable {


    
    var name: String

    
    var emoji: String
    var count: Int
    var dueCount: Int
    init(name: String, count: Int, dueCount: Int){
        self.name = name
        
        self.count = count
        self.dueCount = dueCount
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
            "Polish": "🏰",
            "Persian": "🍢",
            "Ukrainian": "🥟",
            "Portuguese": "🏖️",
            "Swahili" : "🐘"
        ]
        guard let emoji = languagesWithCulturalAndFlagEmojis[name] else {
            self.emoji = ""
        return }
        self.emoji = emoji
            
        
    }
}
struct Card: Equatable, Hashable, Codable, Identifiable {
    var front: String
    var back: String
    var dueDate: Date
    var id: String
    var oldInterval: Int
    init(front: String, back: String, dueDate: Date, id: String?, oldInterval: Int){
        self.front = front
        self.back = back
        self.dueDate = dueDate
        if id == nil {
            print(" 📒 no past card id found. generating new one 📒 ")
            self.id = UUID().uuidString
            
        }
        
        else{
            self.id = id!
        }
        self.oldInterval = oldInterval
        
        
    }
}


struct Certificate: Identifiable {
    let id: String
    let goalMessage: String
    let userMessage: String
    let photoUrl: String?
    let cardIDs: [String]
    let deckName: String
    let date: String
    init(goalMessage: String, userMessage: String, photoUrl: String?, cardIDs: [String], deckName: String, date: String) {
        self.goalMessage = goalMessage
        self.userMessage = userMessage
        self.photoUrl = photoUrl
        self.cardIDs = cardIDs
        self.deckName = deckName
        self.date = date
        if photoUrl != nil{
            self.id = goalMessage + userMessage + photoUrl!
        }
        else{
            self.id = goalMessage + userMessage
        }
    }
}
