//
//  FBError.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-18.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import Foundation


// MARK: - SignIn anonymously Errors
enum SignInAnonymouslyAuthError: Error {
    case noAuthDataResult
}

extension SignInAnonymouslyAuthError: LocalizedError {
    // This will provide me with a specific localized description for the SignInWithAppleAuthError
    var errorDescription: String? {
        switch self {
        case .noAuthDataResult:
            return NSLocalizedString("No Auth Result", comment: "")
        }
    }
}


// MARK: - SignIn with Apple Errors
enum SignInWithAppleAuthError: Error {
    case noAuthDataResult
    case noIdentityToken
    case noIdTokenString
    case noAppleIDCredential
    case noSignInState
    case noUpdatedCredentials
    case noUserSignedIn
}

extension SignInWithAppleAuthError: LocalizedError {
    // This will provide me with a specific localized description for the SignInWithAppleAuthError
    var errorDescription: String? {
        switch self {
        case .noAuthDataResult:
            return NSLocalizedString("No Auth Data Result", comment: "")
        case .noIdentityToken:
            return NSLocalizedString("Unable to fetch identity token", comment: "")
        case .noIdTokenString:
            return NSLocalizedString("Unable to serialize token string from data", comment: "")
        case .noAppleIDCredential:
            return NSLocalizedString("Unable to create Apple ID Credential", comment: "")
        case .noSignInState:
            return NSLocalizedString("Invalid state: request must be started with one of the SignInStates", comment: "")
        case .noUpdatedCredentials:
            return NSLocalizedString("Unable to retrieve updated credentials", comment: "")
        case .noUserSignedIn:
            return NSLocalizedString("Unable to link account, no user signed in", comment: "")
        }
    }
}

// MARK: - Signin in with email errors
public enum EmailAuthError: Error {
    case noAuthDataResult
    case incorrectPassword
    case invalidEmail
    case accoundDoesNotExist
    case unknownError
    case couldNotCreate
    case extraDataNotCreated
    case noUpdatedCredentials
    case noUserSignedIn
}

extension EmailAuthError: LocalizedError {
    // This will provide me with a specific localized description for the EmailAuthError
    public var errorDescription: String? {
        switch self {
        case .noAuthDataResult:
            return NSLocalizedString("No Auth Data Result", comment: "")
        case .incorrectPassword:
            return NSLocalizedString("Incorrect Password for this account", comment: "")
        case .invalidEmail:
             return NSLocalizedString("Not a valid email address.", comment: "")
        case .accoundDoesNotExist:
            return NSLocalizedString("Not a valid email address.  This account does not exist.", comment: "")
        case .unknownError:
            return NSLocalizedString("Unknown error.  Cannot log in.", comment: "")
        case .couldNotCreate:
            return NSLocalizedString("Could not create user at this time.", comment: "")
        case .extraDataNotCreated:
            return NSLocalizedString("Could not save user's full name.", comment: "")
        case .noUpdatedCredentials:
            return NSLocalizedString("Unable to retrieve updated credentials", comment: "")
        case .noUserSignedIn:
            return NSLocalizedString("Unable to link account, no user signed in", comment: "")
        }
    }
}


