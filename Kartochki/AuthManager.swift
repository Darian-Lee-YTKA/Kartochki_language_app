//
//  AuthManager.swift
//  Kartochki
//
//  Created by Darian Lee on 6/4/24.
//


import Foundation
import FirebaseAuth
@Observable
class AuthManager { // Conform to ObservableObject

    var user: User? // Use @Published for observable properties

    init() {
        // TODO: Check for cached user for persisted login
        self.user = Auth.auth().currentUser
    }

    // https://firebase.google.com/docs/auth/ios/start#sign_up_new_users
    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                DispatchQueue.main.async {
                    self.user = authResult.user // Update @Published property
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

    // https://firebase.google.com/docs/auth/ios/start#sign_in_existing_users
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
            Task {
                do {
                    let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                    DispatchQueue.main.async {
                        self.user = authResult.user // Update @Published property
                        completion(true)
                    }
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        }
    

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil // Update @Published property
            }
        } catch {
            print(error)
        }
    }
}


