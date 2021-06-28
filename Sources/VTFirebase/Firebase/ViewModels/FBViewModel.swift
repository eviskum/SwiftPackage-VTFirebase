//
//  File.swift
//  
//
//  Created by Esben Viskum on 17/06/2021.
//

import Foundation
import Firebase
import Combine
import SwiftUI

public class FBViewModel: ObservableObject {
    public enum FBAuthState {
        case undefined, signedOut, signedIn
    }

    @Published public private(set) var user: User? = nil
    @Published public private(set) var isAnonymous = true
    @Published public private(set) var email: String = ""
    @Published public private(set) var displayName: String = ""

    @Published public var fbUser: FBUser
    @Published public private(set) var isUserAuthenticated: FBAuthState
    @Published public private(set) var providerId: FBAuthProviders = .anonymous

//    @AppStorage("fbFirstLogon") var fbFirstLogon = true


//    @Published private var authenticationService = AuthenticationService() // = Resolver.resolve()
    
    private var cancellables = Set<AnyCancellable>()

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    public init() {
        isUserAuthenticated = .undefined
        fbUser = .init(uid: "", name: "", email: "")
        
        registerStateListener()

        self.$user.compactMap { user in
            user?.isAnonymous
        }
        .assign(to: \.isAnonymous, on: self)
        .store(in: &cancellables)

        self.$user.compactMap { user in
            user?.isAnonymous
        }
        .sink(receiveValue: { isAnonymous in
            if isAnonymous {
                self.email = ""
                self.displayName = "Anonymous"
            }
        })
        .store(in: &cancellables)
        
        self.$user.compactMap { user in
            print("User email: \(user?.email ?? "no email")")
            return user?.email
        }
        .assign(to: \.email, on: self)
        .store(in: &cancellables)
        
        self.$user.compactMap { user in
            user?.displayName
        }
        .assign(to: \.displayName, on: self)
        .store(in: &cancellables)
        
        self.$user.compactMap { user in
            let providerIds = user?.providerData.map { $0.providerID }
            if let providerIds = providerIds {
                if providerIds.count > 0 {
                    return FBAuthProviders.getAuthProviderType(providerId: providerIds[0])
                } else {
                    return FBAuthProviders.anonymous
                }
            }
            return nil
        }
        .assign(to: \.providerId, on: self)
        .store(in: &cancellables)
     
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
                // We are signed in
                self.isUserAuthenticated = .signedIn
                let anonymous = user.isAnonymous ? "anonymously " : ""
                
                print("User signed in \(anonymous)with user ID \(user.uid). Email: \(user.email ?? "(empty)"), display name: [\(user.displayName ?? "(empty)")]")
                
//                FBFirestore.retrieveFBUser(uid: user.uid) { (result) in
//                    switch result {
//                    case .failure(let error):
//                        print(error.localizedDescription)
//                    case .success(let fbUser):
//                        print("FBUser retrieved")
//                        self.fbUser = fbUser
//                    }
//                }
            }
            else {
                self.isUserAuthenticated = .signedOut
                print("User signed out.")
//                self.signIn()
            }
        }
    }

}
