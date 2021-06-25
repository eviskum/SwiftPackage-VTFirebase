//
//  File.swift
//  
//
//  Created by Esben Viskum on 16/06/2021.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth


public class SignInWithAppleCoordinator: NSObject {
    //  @LazyInjected private var taskRepository: TaskRepository
    //  @LazyInjected private var authenticationService: AuthenticationService
    private var fbVM : FBViewModel
    
    private weak var window: UIWindow!
    private var completion: ((Result<AuthDataResult, Error>) -> ())?
    
    private var currentNonce: String?
    
    public init(window: UIWindow?, fbVM: FBViewModel) {
        self.window = window
        self.fbVM = fbVM
    }
    
    private func appleIDRequest(withState: SignInState) -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.state = withState.rawValue
        
        let nonce = FBAuth.randomNonceString()
        currentNonce = nonce
        request.nonce = FBAuth.sha256(nonce)
        
        return request
    }
    
    public func signIn(completion: @escaping (Result<AuthDataResult, Error>) -> ()) {
        self.completion = completion
        
        let request = appleIDRequest(withState: .signIn)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    public func link(completion: @escaping (Result<AuthDataResult, Error>) -> ()) {
        self.completion = completion
        
        let request = appleIDRequest(withState: .link)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
}

extension SignInWithAppleCoordinator: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let completion = completion else {
            fatalError("No completion handler")
        }

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            completion(.failure(SignInWithAppleAuthError.noAppleIDCredential))
            return
        }
        
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            completion(.failure(SignInWithAppleAuthError.noIdentityToken))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
            completion(.failure(SignInWithAppleAuthError.noIdTokenString))
            return
        }
        
        guard let stateRaw = appleIDCredential.state, let state = SignInState(rawValue: stateRaw) else {
            print("Invalid state: request must be started with one of the SignInStates")
            completion(.failure(SignInWithAppleAuthError.noSignInState))
            return
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        
        switch state {
        case .signIn:
            Auth.auth().signIn(with: credential) { (result, error) in
                if let error = error {
                    print("Error authenticating: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let result = result else {
                    print("Error: No AuthDataResult returned")
                    completion(.failure(SignInWithAppleAuthError.noAuthDataResult))
                    return
                }
                
                self.updateDisplayName(appleIDCredential: appleIDCredential) { err in
                    if let err = err {
                        completion(.failure(err))
                    } else {
                        completion(.success(result))
                    }
                }
            }
            
        case .link:
            guard let currentUser = Auth.auth().currentUser else {
                print("Error: no active user logged in")
                completion(.failure(SignInWithAppleAuthError.noUserSignedIn))
                return
            }
            
            currentUser.link(with: credential) { (result, error) in
                if let error = error, (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                    print("The user you're signing in with has already been linked, signing in to the new user and migrating the anonymous users [\(currentUser.uid)] tasks.")
                    
                    guard let updatedCredential = (error as NSError).userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? OAuthCredential else {
                        completion(.failure(SignInWithAppleAuthError.noUpdatedCredentials))
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
                            completion(.failure(SignInWithAppleAuthError.noAuthDataResult))
                            return
                        }

                        self.updateDisplayName(appleIDCredential: appleIDCredential) { err in
                            if let err = err {
                                completion(.failure(err))
                            } else {
                                completion(.success(result))
                            }
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
                    completion(.failure(SignInWithAppleAuthError.noAuthDataResult))
                    return
                }

                self.updateDisplayName(appleIDCredential: appleIDCredential) { err in
                    if let err = err {
                        completion(.failure(err))
                    } else {
                        completion(.success(result))
                    }
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
                    completion(.failure(SignInWithAppleAuthError.noAuthDataResult))
                    return
                }

                self.updateDisplayName(appleIDCredential: appleIDCredential) { err in
                    if let err = err {
                        completion(.failure(err))
                    } else {
                        completion(.success(result))
                    }
                }
            })
        }
    }
    
    
    private func updateDisplayName(appleIDCredential: ASAuthorizationAppleIDCredential, completionHandler: @escaping (Error?) -> Void) {
        guard let fullName = appleIDCredential.fullName else {
            completionHandler(nil)
            return
        }
        
        if let givenName = fullName.givenName, let familyName = fullName.familyName {
            let displayName = "\(givenName) \(familyName)"

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
        else {
            completionHandler(nil)
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error.localizedDescription)")
    }
    
}

extension SignInWithAppleCoordinator: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
    }
}
