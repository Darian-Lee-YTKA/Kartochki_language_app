//
//  KartochkiApp.swift
//  Kartochki
//
//  Created by Darian Lee on 6/4/24.
//




import SwiftUI
import FirebaseCore

@main
struct KartochkiApp: App {

        
    @State private var authManager: AuthManager
 
        init() {
            FirebaseApp.configure()
            authManager = AuthManager()
            
            
            
        }

        var body: some Scene {
            WindowGroup {
                ViewAndAlertManager()
                        .environment(authManager)
                            
            }
        }
    }


//import SwiftUI
//import FirebaseCore
//
//@main
//struct KartochkiApp: App {
//
//        
//    @State private var authManager: AuthManager
//        
//        init() {
//            FirebaseApp.configure()
//            authManager = AuthManager()
//            
//        }
//
//        var body: some Scene {
//            WindowGroup {
//                
//                if authManager.user != nil {
//                    ViewAndAlertManager(currentView: .DecksView)
//                        .environment(authManager)
//                            } else {
//                                ViewAndAlertManager(currentView: .LoginView)
//                                    .environment(authManager)
//                            }
//            }
//        }
//    }
