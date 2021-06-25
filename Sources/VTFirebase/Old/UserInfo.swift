//
//  UserInfo.swift
//  Firebase Auth
//
//  Created by Esben Viskum on 08/06/2021.
//

import Foundation
import FirebaseAuth

public class UserInfo: ObservableObject {
    public enum FBAuthState {
        case undefined, signedOut, signedIn
    }
//    @Published var isUserAuthenticated: FBAuthState = .undefined
//    @Published var user: FBUser = .init(uid: "", name: "", email: "")
    @Published public var isUserAuthenticated: FBAuthState
    @Published public var user: FBUser

    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    public var isAnonymous: Bool? {
        Auth.auth().currentUser?.isAnonymous
    }
    
    public var providerIds: [String]? {
        Auth.auth().currentUser?.providerData.map { $0.providerID }
    }
    
    public var signedInWith: FBAuthProviders? {
        if let providerIds = providerIds {
            if providerIds.count > 0 {
                return FBAuthProviders.getAuthProviderType(providerId: providerIds[0])
            } else {
                return FBAuthProviders.anonymous
            }
        }
        return nil
    }
    
    public var accountLinkedWith: [FBAuthProviders]? {
        if let providerIds = providerIds {
            return providerIds.map {
                FBAuthProviders.getAuthProviderType(providerId: $0)
            }
        }
        return nil
    }
    
    public init() {
        isUserAuthenticated = .undefined
        user = .init(uid: "", name: "", email: "")
    }
    
    public func configureFirebaseStateDidChange() {
        // self.isUserAuthenticated = .signedOut
        // self.isUserAuthenticated = .signedIn
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener({ (_, user) in
            // print("State change fired")
            guard let currentUser = user else {
                self.isUserAuthenticated = .signedOut
                return
            }
            self.isUserAuthenticated = .signedIn
            FBFirestore.retrieveFBUser(uid: currentUser.uid) { (result) in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let user):
                    // print("FBUser updated")
                    self.user = user
                }
            }
        })
    }
    
    public func retrieveFBUser() {
        if let user = Auth.auth().currentUser {
            FBFirestore.retrieveFBUser(uid: user.uid) { (result) in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let user):
                    self.user = user
                }
                return
            }
        }
    }
}
