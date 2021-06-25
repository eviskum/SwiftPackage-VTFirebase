//
//  SignInAnonymouslyCoordinator.swift
//  
//
//  Created by Esben Viskum on 21/06/2021.
//

import Foundation
import AuthenticationServices
import FirebaseAuth


public class SignInAnonymouslyCoordinator {
    private var fbVM : FBViewModel
    private var completion: ((Result<AuthDataResult, Error>) -> ())?

    public init(fbVM: FBViewModel) {
        self.fbVM = fbVM
    }

    public func signIn(completion: @escaping (Result<AuthDataResult, Error>) -> ()) {
        self.completion = completion
        
        authorizationController()
    }
}


extension SignInAnonymouslyCoordinator {
    fileprivate func authorizationController() {
        guard let completion = completion else {
            fatalError("No completion handler")
        }

        Auth.auth().signInAnonymously { (result, error) in
            if let error = error {
                print("Error authenticating: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let result = result else {
                print("Error: No AuthDataResult returned")
                completion(.failure(SignInAnonymouslyAuthError.noAuthDataResult))
                return
            }
            
            completion(.success(result))
        }
    }
}
