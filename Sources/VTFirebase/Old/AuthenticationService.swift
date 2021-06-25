//
//  File.swift
//  
//
//  Created by Esben Viskum on 17/06/2021.
//

import Foundation
import Firebase

class AuthenticationService: ObservableObject {
    public enum FBAuthState {
        case undefined, signedOut, signedIn
    }

    @Published var user: User?
//    @Published public var isUserAuthenticated: FBAuthState
    @Published public var isUserAuthenticated: FBAuthState
    @Published public var fbUser: FBUser

    
    //  @LazyInjected private var taskRepository: TaskRepository
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        isUserAuthenticated = .undefined
        fbUser = .init(uid: "", name: "", email: "")
        registerStateListener()
    }
    
    func signIn() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("Error when trying to sign out: \(error.localizedDescription)")
        }
    }
    
    func updateDisplayName(displayName: String, completionHandler: @escaping (Result<User, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { error in
                if let error = error {
                    completionHandler(.failure(error))
                }
                else {
                    if let updatedUser = Auth.auth().currentUser {
                        print("Successfully updated display name for user [\(user.uid)] to [\(updatedUser.displayName ?? "(empty)")]")
                        // force update the local user to trigger the publisher
                        self.user = updatedUser
                        completionHandler(.success(updatedUser))
                    }
                }
            }
        }
    }

    
    private func registerStateListener() {
        if let authStateDidChangeListenerHandle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(authStateDidChangeListenerHandle)
        }
        self.authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("Sign in state has changed.")
            self.user = user
            
            if let user = user {
                self.isUserAuthenticated = .signedOut
                let anonymous = user.isAnonymous ? "anonymously " : ""
                
                print("User signed in \(anonymous)with user ID \(user.uid). Email: \(user.email ?? "(empty)"), display name: [\(user.displayName ?? "(empty)")]")
                
                FBFirestore.retrieveFBUser(uid: user.uid) { (result) in
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(let fbUser):
                        print("FBUser retrieved")
                        self.fbUser = fbUser
                    }
                }
            }
            else {
                self.isUserAuthenticated = .signedOut
                print("User signed out.")
//                self.signIn()
            }
        }
    }

}
