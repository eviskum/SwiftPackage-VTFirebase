//
//  SignInWithEmailCoordinator.swift
//  
//
//  Created by Esben Viskum on 20/06/2021.
//

import Foundation
import AuthenticationServices
import FirebaseAuth


public class SignInWithEmailCoordinator {
    private var fbVM : FBViewModel
    private var completion: ((Result<AuthDataResult, Error>) -> ())?

    public init(fbVM: FBViewModel) {
        self.fbVM = fbVM
    }

    public func signIn(displayName: String? = nil, email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> ()) {
        self.completion = completion
        
        authorizationController(withState: .signIn, displayName: displayName, email: email, password: password)
    }
    
    public func link(displayName: String? = nil, email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> ()) {
        self.completion = completion
        
        authorizationController(withState: .link, displayName: displayName, email: email, password: password)
    }
}


extension SignInWithEmailCoordinator {
    fileprivate func authorizationController(withState: SignInState, displayName: String? = nil, email: String, password: String) {
        guard let completion = completion else {
            fatalError("No completion handler")
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        switch withState {
        case .signIn:
            Auth.auth().signIn(with: credential) { (result, error) in
                if let error = error {
                    print("Error authenticating: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let result = result else {
                    print("Error: No AuthDataResult returned")
                    completion(.failure(EmailAuthError.noAuthDataResult))
                    return
                }
                
                if let displayName = displayName {
                    self.updateDisplayName(displayName: displayName) { err in
                        if let err = err {
                            completion(.failure(err))
                        } else {
                            completion(.success(result))
                        }
                    }
                } else {
                    completion(.success(result))
                }
            }
            
        case .link:
            guard let currentUser = Auth.auth().currentUser else {
                print("Error: no active user logged in")
                completion(.failure(EmailAuthError.noUserSignedIn))
                return
            }
            
            currentUser.link(with: credential) { (result, error) in
                if let error = error, (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                    print("The user you're signing in with has already been linked, signing in to the new user and migrating the anonymous users [\(currentUser.uid)] tasks.")
                    
                    guard let updatedCredential = (error as NSError).userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? OAuthCredential else {
                        completion(.failure(EmailAuthError.noUpdatedCredentials))
                        print("Error: unable to retrieve updated credentials")
                        return
                    }

                    print("Signing in using the updated credentials")

                    Auth.auth().signIn(with: updatedCredential) { (result, error) in
                        if let error = error {
                            print("Error authenticating: \(error.localizedDescription)")
                            completion(.failure(error))
                            return
                        }

                        guard let result = result else {
                            print("Error: No AuthDataResult returned")
                            completion(.failure(EmailAuthError.noAuthDataResult))
                            return
                        }

                        if let displayName = displayName {
                            self.updateDisplayName(displayName: displayName) { err in
                                if let err = err {
                                    completion(.failure(err))
                                } else {
                                    completion(.success(result))
                                }
                            }
                        } else {
                            completion(.success(result))
                        }

                    }
                    return
                }
                else if let error = error {
                    completion(.failure(error))
                    print("Error trying to link user: \(error.localizedDescription)")
                    return
                }

                guard let result = result else {
                    print("Error: No AuthDataResult returned")
                    completion(.failure(EmailAuthError.noAuthDataResult))
                    return
                }

                if let displayName = displayName {
                    self.updateDisplayName(displayName: displayName) { err in
                        if let err = err {
                            completion(.failure(err))
                        } else {
                            completion(.success(result))
                        }
                    }
                } else {
                    completion(.success(result))
                }
            }

        case .reauth:
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error) in
                if let error = error {
                    print("Error authenticating: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let result = result else {
                    print("Error: No AuthDataResult returned")
                    completion(.failure(EmailAuthError.noAuthDataResult))
                    return
                }

                if let displayName = displayName {
                    self.updateDisplayName(displayName: displayName) { err in
                        if let err = err {
                            completion(.failure(err))
                        } else {
                            completion(.success(result))
                        }
                    }
                } else {
                    completion(.success(result))
                }
            })
        }
    }
    
    
    private func updateDisplayName(displayName: String, completionHandler: @escaping (Error?) -> Void) {
        if displayName.count == 0 {
            completionHandler(nil)
            return
        }
        
        self.fbVM.updateDisplayName(displayName: displayName) { result in
            switch result {
            case .success(let user):
                print("Succcessfully update the user's display name: \(String(describing: user.displayName))")
                completionHandler(nil)
                
            case .failure(let error):
                print("Error when trying to update the display name: \(error.localizedDescription)")
                completionHandler(error)
            }
        }
    }
}
