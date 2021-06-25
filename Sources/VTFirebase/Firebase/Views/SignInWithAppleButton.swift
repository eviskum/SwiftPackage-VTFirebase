//
//  SignInWithAppleButton.swift
//  
//
//  Created by Esben Viskum on 18/06/2021.
//

import SwiftUI
import AuthenticationServices

public struct SignInWithAppleButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    public init() {
        
    }
    
    public var body: some View {
        Group {
            if colorScheme == .light {
                SignInWithAppleButtonInternal(colorScheme: .light, buttonType: .signIn)
            }
            else {
                SignInWithAppleButtonInternal(colorScheme: .dark, buttonType: .signIn)
            }
        }
    }
}

public struct SignUpWithAppleButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    public init() {
        
    }
    
    public var body: some View {
        Group {
            if colorScheme == .light {
                SignInWithAppleButtonInternal(colorScheme: .light, buttonType: .signUp)
            }
            else {
                SignInWithAppleButtonInternal(colorScheme: .dark, buttonType: .signUp)
            }
        }
    }
}

public struct ContinueWithAppleButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    public init() {
        
    }
    
    public var body: some View {
        Group {
            if colorScheme == .light {
                SignInWithAppleButtonInternal(colorScheme: .light, buttonType: .continue)
            }
            else {
                SignInWithAppleButtonInternal(colorScheme: .dark, buttonType: .continue)
            }
        }
    }
}


fileprivate struct SignInWithAppleButtonInternal: UIViewRepresentable {
    var colorScheme: ColorScheme
    var buttonType: ASAuthorizationAppleIDButton.ButtonType
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        switch colorScheme {
        case .light:
            return ASAuthorizationAppleIDButton(type: buttonType, style: .black)
        case .dark:
            return ASAuthorizationAppleIDButton(type: buttonType, style: .white)
        @unknown default:
            return ASAuthorizationAppleIDButton(type: buttonType, style: .black)
        }
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}

struct SignInWithAppleButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithAppleButton()
    }
}
