//
//  File.swift
//  
//
//  Created by Esben Viskum on 15/06/2021.
//

import Foundation

public enum FBAuthProviders {
    case anonymous
    case email
    case phone
    case facebook
    case twitter
    case google
    case apple
    case other
    
    static public func getAuthProviderType(providerId: String) -> Self {
        switch providerId {
        case "password":
            return .email
        case "phone":
            return .phone
        case "facebook.com":
            return .facebook
        case "twitter.com":
            return .twitter
        case "google.com":
            return .google
        case "apple.com":
            return .apple
        default:
            return .other
        }
    }
    
    public var providerName: String {
        switch self {
        case .anonymous:
            return "anonymous"
        case .email:
            return "email/password"
        case .phone:
            return "phone"
        case .facebook:
            return "Facebook"
        case .twitter:
            return "Twitter account"
        case .google:
            return "Google"
        case .apple:
            return "Apple"
        case .other:
            return "other"
        }
    }

    public var providerSignInString: String {
        switch self {
        case .anonymous:
            return "Signed in anonymously"
        case .email:
            return "Signed in with email/password"
        case .phone:
            return "Signed in with phone"
        case .facebook:
            return "Signed in with Facebook account"
        case .twitter:
            return "Signed in with Twitter account"
        case .google:
            return "Signed in with Google account"
        case .apple:
            return "Signed in with Apple ID"
        case .other:
            return "Signed in with other method"
        }
    }

}
