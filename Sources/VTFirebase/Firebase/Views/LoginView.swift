//
//  LoginView.swift
//  Firebase Auth
//
//  Created by Esben Viskum on 08/06/2021.
//

import SwiftUI

public struct LoginView: View {
//    @EnvironmentObject var userInfo: UserInfo
    @Environment(\.window) var window: UIWindow?
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var fbVM: FBViewModel
    @State var signInAppleHandler: SignInWithAppleCoordinator?
    @State var signInEmailHandler: SignInWithEmailCoordinator?
    @State var signInAnonymousHandler: SignInAnonymouslyCoordinator?

    
    enum Action: Identifiable {
        case signUp
        case resetPW
        
        var id: Int {
            hashValue
        }
    }
    
    public init() {
        
    }
    
    @State private var action: Action?
    
    public var body: some View {
        VStack {
            SignInAnonymouslyButton()
                .frame(height: 45)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.signInAnonymouslyButtonTapped()
                }

            SignInWithAppleButton()
                .frame(height: 45)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.signInWithAppleButtonTapped()
                }

            SignInWithEmailButton()
                .frame(height: 45)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.action = .signUp
//                    self.signInWithEmailButtonTapped()
                }


//            SignInWithEmailView(action: $action)
//            SignInWithAppleView()
//                .frame(width: 200, height: 50)
//            SignInAnonymouslyView()
//                .frame(width: 200, height: 45)
            Spacer()
        }
        .sheet(item: $action) { item in
            switch item {
            case .signUp:
                SignUpView()
            case .resetPW:
                ForgotPasswordView()
            }
        }
    }
    
    func signInWithAppleButtonTapped() {
        signInAppleHandler = SignInWithAppleCoordinator(window: self.window, fbVM: fbVM)
        signInAppleHandler?.link { (result) in
            switch result {
            case .failure(let error):
                print("Unable to link Apple ID. Error: \(error.localizedDescription)")
            case .success(let authDataResult):
                print("User \(authDataResult.user.displayName ?? "") linked")
            }
        }
    }

    func signInWithEmailButtonTapped() {
        signInEmailHandler = SignInWithEmailCoordinator(fbVM: fbVM)
        signInEmailHandler?.link(displayName: "Esben Email",
                                 email: "",
                                 password: "") { (result) in
            switch result {
            case .failure(let error):
                print("Unable to link Apple ID. Error: \(error.localizedDescription)")
            case .success(let authDataResult):
                print("User \(authDataResult.user.displayName ?? "") linked")
            }
        }
    }

    func signInAnonymouslyButtonTapped() {
        signInAnonymousHandler = SignInAnonymouslyCoordinator(fbVM: fbVM)
        signInAnonymousHandler?.signIn { (result) in
            switch result {
            case .failure(let error):
                print("Unable to link Apple ID. Error: \(error.localizedDescription)")
            case .success(let authDataResult):
                print("User \(authDataResult.user.displayName ?? "") linked")
            }
        }
    }

}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
